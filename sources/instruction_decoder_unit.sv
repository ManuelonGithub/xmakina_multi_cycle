`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/20/2019 05:43:34 PM
// Design Name: 
// Module Name: instruction_decoder_unit
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module instruction_decoder_unit
#(parameter DEBUG = 0)
(
    input wire clk, reset, en,
    input wire[15:0] inst_data,
    
    output reg branch_en, new_status_en,
    output reg[1:0] reg_wb_mode,
    output reg[2:0] branch_cond, macro_op,
    output reg[3:0] status_wr_mode,

    output reg[2:0] dst, src_a, src_b,
    output reg[15:0] imm_val, addr_offset, branch_offset,

    output reg byte_inst,
    output reg[3:0] alu_func,
    output reg imm_val_sel, offset_sel, const_sel,
    output reg mem_wr, pc_wr
);

    localparam BL_OFF_H = 12, CB_OFF_H = 9, B_OFF_L = 0;
    localparam CB_COND_H = 12, CB_COND_L = 10;
    
    localparam ALU_OP_H = 11, ALU_OP_L = 7;
    
    localparam SRC_TYPE = 7;
    localparam BYTE_OP = 6;
    
    localparam SRC_OP_H = 5, DST_OP_H = 2, OP_L = 0;
    
    localparam IMM_OP_H = 12, IMM_OP_L = 11;
    localparam IMM_VAL_H = 10, IMM_VAL_L = 3;
    
    localparam ADDE_OFF_H = 13, ADDR_OFF_L = 7;

    typedef enum logic[2:0] {
        BRANCH_W_LINK, 
        CONDITIONAL_BRANCH, 
        ALU_OPERATION,
        LOAD,
        STORE,
        SYSTEM_CALL,
        CONDITIONAL_EXEC,
        IMMEDIATE_MOVE
    } MACRO_OPS;

    typedef enum logic[1:0] {
        MOVL, 
        MOVLZ, 
        MOVLS, 
        MOVH
    } IMM_MOV_FUNC;

    typedef enum logic[3:0] {
        EQUAL,
        NOT_EQUAL,
        CARRY,
        NO_CARRY,
        NEGATIVE,
        GREATER_OR_EQUAL,
        LESS,
        ALWAYS,
        NO_BRANCH
    } BRANCH_CONDITIONS;

    typedef enum logic[3:0] {
        ADD, // Functions pertaining ALU block 0
        ADDC,
        SUB, 
        SUBC,

        XOR, // Functions pertaining ALU block 1
        AND, 
        BIC, 
        BIS, 

        SRA, // Functions pertaining ALU block 2
        RRC,
        NA0, // Only has two functions so need to fill the enum
        NA1, // with N/A's

        MOV, // Functions pertaining ALU block 3
        SWPB, 
        SXT
    } ALU_FUNCTIONS;

    typedef enum logic[4:0] {
        R0,
        R1,
        R2,
        R3,
        R4,
        R5,
        R6,
        R7,
        C0,
        C1,
        C2,
        C3,
        C4,
        C5,
        C6,
        C7,
        IMM_VAL,
        ADDR_OFFSET,
        NONE
    } OPERANDS;

    typedef enum logic[1:0] {
        NO_WRITE,
        LOW_BYTE,
        HIGH_BYTE,
        WORD
    } REG_WRITE_MODE;

    typedef struct packed {
        MACRO_OPS macro_op;
        BRANCH_CONDITIONS branch_cond;
        ALU_FUNCTIONS ALU_func;
        OPERANDS src_a, src_b, dst;
        REG_WRITE_MODE wb_mode;
    } decoder_debug_t;  

    decoder_debug_t debug;

    reg[15:0] inst;

    reg[1:0] alu_wb, imm_mov_wb;
    reg[3:0] alu_op_func;


    initial begin
        inst <= 0;
    end

    always @ (*) begin : DEBUG_CONSTRUCTS
        if (DEBUG) begin
            debug.macro_op <= MACRO_OPS'(macro_op);
            debug.branch_cond <= BRANCH_CONDITIONS'(branch_cond);
            debug.ALU_func <= ALU_FUNCTIONS'(alu_func);
            debug.src_a <= OPERANDS'(src_a);

            if (const_sel)
                debug.src_b <= OPERANDS'({1'b1,src_b});
            else if (imm_val_sel)
                debug.src_b <= IMM_VAL;
            else if (offset_sel)
                debug.src_b <= ADDR_OFFSET;
            else
                debug.src_b <= OPERANDS'(src_b);

            if (reg_wb_mode == 0)
                debug.dst <= NONE;
            else
                debug.dst <= OPERANDS'(dst);

            debug.wb_mode <= REG_WRITE_MODE'(reg_wb_mode);
        end
        else
            debug <= 0;
    end
    
    always @ (posedge clk) begin : INSTRUCTION_DATA_REGISTER
        if (reset)
            inst <= 0;
        else if (en)
            inst <= inst_data;
    end

    always @ (*) begin : REGISTER_OPERAND_DECODING
        case (inst[15:13]) inside
            3'b000: begin   // Branch with link
                dst <= 4;
                src_a <= 7;
                src_b <= 7;
            end

            3'b10?: begin   // Load
                dst <= inst[2:0];
                src_a <= inst[5:3];
                src_b <= inst[2:0];
            end

            default: begin
                dst   <= inst[2:0];
                src_a <= inst[2:0];
                src_b <= inst[5:3];
            end
        endcase
    end
    
    always @ (*) begin : IMMEDIATE_OPERANDS_DECODING
        addr_offset <= {{9{inst[13]}}, inst[13:7]};
        
        if (inst[13])   // Conditional branch
            branch_offset <= {{5{inst[9]}}, inst[9:0], 1'b0};
        else
            branch_offset <= {{2{inst[12]}}, inst[12:0], 1'b0};

        imm_val[7:0] = inst[10:3];
        case (inst[12:11]) 
            MOVL:
                imm_val[15:8] <= inst[10:3];
            MOVLZ:
                imm_val[15:8] <= 8'h0;
            MOVLS:
                imm_val[15:8] <= 8'hFF;
            MOVH:
                imm_val[15:8] <= inst[10:3];
        endcase
    end

    always @ (*) begin : EXECUTION_UNIT_OPERANDS_DECODING
        /* 
         * Tells the execution unit which condition to check
         * on a branch operation.
         */
        if (inst[13])
            branch_cond <= inst[12:10];
        else
            branch_cond <= 'b111;

        branch_en <= (inst[15:14] == 0);
        new_status_en <= (inst[15:12] == 4'b0100);

        /*
         * Determines how an immediate move operation writes back 
         * writes back to the Register File.
         */
        case (inst[12:11])
            MOVL:
                imm_mov_wb <= 2'b01;
            MOVH:
                imm_mov_wb <= 2'b10;
            default:
                imm_mov_wb <= 2'b11;
        endcase

        /*
         * Determines if an ALU operation does not write back.
         * The two operations to single out are CMP & BIT.
         * These two have a unique bit-sequence in instruction's bits 11:8,
         * which will differentiate them from the other ALU instructions.
         * The bit-sequence for CMP = 0101, & BIT = 1000.
         */
        case (inst[11:8]) inside 
            4'b0101, 4'b1000:
                alu_wb <= 'b00;
            default:
                alu_wb <= {~byte_inst, 1'b1};
        endcase

        /*
         * Determines how the decoded operation will write back 
         * to the register file.
         */
        case (inst[15:10]) inside
            6'b000???:
                reg_wb_mode <= 'b11;
            6'b0100??:
                reg_wb_mode <= alu_wb;
            6'b10????, 6'b010100:
                reg_wb_mode <= {~byte_inst, 1'b1};
            6'b011???:
                reg_wb_mode <= imm_mov_wb;
            default:
                reg_wb_mode <= 'b00;
        endcase
    end
    
    always @ (*) begin : CONTROL_SIGNALS_DECODING
        byte_inst <= inst[6];

        case (inst[15:13]) inside // ALU function select control
            3'b000, 3'b011:     // Immediate move
                alu_func <= MOV;
            3'b1??:     // Load or store
                alu_func <= ADD;
            default: 
                alu_func <= alu_op_func;
        endcase

        case (inst[15:13]) inside // ALU source select control
            3'b011: begin   // Immediate move
                const_sel <= 0;
                imm_val_sel <= 1;
                offset_sel <= 0;
            end

            3'b1??: begin   // Load or store
                const_sel <= 0;
                imm_val_sel <= 0;
                offset_sel <= 1;
            end

            default: begin
                const_sel <= inst[7];
                imm_val_sel <= 0;
                offset_sel <= 0;
            end
        endcase

        case (inst[15:13]) inside // Write-back select control
            3'b000: begin   // Branch with link
                mem_wr <= 0;
                pc_wr <= 1;
            end

            3'b11?: begin   // Store
                mem_wr <= 1;
                pc_wr <= 0;
            end

            default: begin
                mem_wr <= 0;
                pc_wr <= 0;
            end
        endcase

        case(alu_op_func[3:2])
            0:  // Arrithmetic operation
                status_wr_mode <= 4'b1111;
            1:  // Boolean Logic operation
                status_wr_mode <= 4'b0110;
            2:  // Shift/Rotate operation
                status_wr_mode <= 4'b1110;
            3:  // Manipulation operation
                status_wr_mode <= 4'b0000;
        endcase
    end
    
    /*
     * This block determines which function the ALU will perform
     * if the instruction relates to an ALU macro-operation.
     * (memory accesses & immediate move require the ALU and so need to 
     *  overwrite the alu function.)
     * For an ALU macro-op, bits 11:7 of the instruction provides all the 
     * information required to determine which ALU function will be performed.
     */
    always @ (*) begin : ALU_OPERATION_DECODING 
        case (inst[11:7]) inside
            5'b0000?, 5'b0100?:         // inst. ADD & DADD
                alu_op_func <= ADD;
            5'b0001?:                   // inst. ADDC
                alu_op_func <= ADDC;
            5'b0010?, 5'b0101?:         // inst. SUB & CMP
                alu_op_func <= SUB;
            5'b0011?:                   // inst. SUBC
                alu_op_func <= SUBC;
            5'b0110?:                   // inst. XOR
                alu_op_func <= XOR;
            5'b0111?, 5'b1000?:         // inst. AND & BIT
                alu_op_func <= AND;
            5'b1001?:                   // inst. BIC
                alu_op_func <= BIC;
            5'b1010?:                   // inst. BIS
                alu_op_func <= BIS;
            5'b1011?, 5'b1100?:         // inst. MOV & SWAP
                alu_op_func <= MOV;
            5'b1101?:                   // inst. SRA
                alu_op_func <= SRA;
            5'b1110?:                   // inst. RRC
                alu_op_func <= RRC;
            5'b11110:                   // inst. SWPB
                alu_op_func <= SWPB;
            5'b11111:                   // inst. SXR
                alu_op_func <= SXT;
        endcase
    end

    always @ (*) begin : MACRO_OP_DECODING
        case (inst[15:10]) inside
            6'b000???:
                macro_op <= BRANCH_W_LINK;
            6'b001???:
                macro_op <= CONDITIONAL_BRANCH;
            6'b0100??:
                macro_op <= ALU_OPERATION;
            6'b10????, 6'b010100:
                macro_op <= LOAD;
            6'b11????, 6'b010101:
                macro_op <= STORE;
            6'b010110:
                macro_op <= SYSTEM_CALL;
            6'b010111:
                macro_op <= CONDITIONAL_EXEC;
            6'b011???:
                macro_op <= IMMEDIATE_MOVE;
        endcase
    end 
    
endmodule
