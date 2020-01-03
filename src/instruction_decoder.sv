/**
 * @File    X-Makina Instruction decoder Module file.
 * @brief   Contains the code for the X-Makina Instruction decoder.
 * @author  Manuel Burnay
 * @date    2019.10.25 (created)
 * @date    2019.10.25 (Last Modified)
 */

/**
 * @brief	X-Makina Multi-cycle hard-coded instruction decoder.
 * @input  	inst: 			instruction word.
 * @output 	opcode: 		Instruction operation code.
 * @output 	byte_inst:		Byte Intruction variant signal.
 * @output 	dst_reg:		Destination Register Address.
 * @output 	src_reg:		Source Register Address.
 * @output 	alu_wb:			Determines if an ALU operation 
 *							should write back to the register file.
 * @output 	update_status:	Determines if an ALU operation should update the status.
 * @output 	Reg_or_Const:	Determines the source of the ALU's B-operand for 
 * 							an ALU operation.
 * @output 	ALU_op:			ALU operation control signal.
 * @output 	branch_cond:	Branch condition control signal.
 * @output 	branch_offset:	Branch offset data word.
 * @output 	addr_PREPO:		Load/Store address pre/post ALU control signal.
 * @output 	addr_DEC:		Load/Store address decrement control signal.
 * @output 	addr_INC:		Load/Store address increment control signal.
 * @output 	mem_offset:		Load/Store Relative memory offset data word.
 * @output 	imm_wb:			Move-Immediate write-back mode.
 * @output 	imm_val:		Immediate value data word.
 * @param   WORD: Specifies the size of the instruction words in bits.
 * @details This decoder uses hardcoded logic to retrieve relevant 
 *			information that the control unit uses throughout its procedure.
 *			It has a WORD parameter, but that is simply a module standard,
 *			it has no real effect on the decoding procedure.
 */
module instruction_decoder
#(
	parameter WORD = 16
 )
(
	input wire[WORD-1:0] inst,

	// Signals Used in most instructions
	output reg[3:0] opcode,
	output reg byte_inst,
	output reg[2:0] dst_reg, src_reg,

	// ALU instruction signals
	output reg alu_wb, update_status, 
	output reg Reg_or_Const,
	output reg[3:0] ALU_op,

	// Branch instruction signals
	output reg[2:0] branch_cond,
	output reg[WORD-1:0] branch_offset,

	// Load and Store instruction signals
	output reg addr_PREPO, addr_DEC, addr_INC, 

	// Load and Store Relative instruction signals
	output reg[WORD-1:0] mem_offset,

	// Move Immendiate instruction signals
	output reg[1:0] imm_wb,
	output reg[WORD-1:0] imm_val
);

	enum {
		BRANCH_WITH_LINK, BRANCH_CONDITIONAL,
		ALU, SHIFT,
		SWAP,
		LOAD,
		STORE,
		SYSTEM_CALL,
		CONDITIONAL_EXEC,
		MOVE_IMMEDIATE,
		LOAD_RELATIVE,
		STORE_RELATIVE,
		BAD_OPCODE
	} XMAKINA_OPCODES;

	enum {
        ADD, ADDC, 
        SUB, SUBC,
		XOR, AND, 
		BIC, BIS,
		PASS_B, PASS_A,
        SWPB, SXT
    } ALU_FUNCTIONS;

    enum {SRA, RRC} SHIFT_OPERATIONS;

	always @ (*) begin

		// Opcode decoding
		// Waterfall-style decoding
		// Should look into ROM-based decoding though.
		// Would make the decoder a lot more re-configurable.
		case (inst[15:14])
			2'b00: begin	// Only Branch instructions fall here
				if (inst[14]) 		opcode <= BRANCH_CONDITIONAL;
				else				opcode <= BRANCH_WITH_LINK;
			end
			2'b01: begin	// A whole whackton of stuff falls here
				case (inst[13:12])
					2'b00: begin	// Swap, Shift or ALU instructions fall here
						case (inst[11:8])
							4'b1100: opcode <= SWAP;
							default: opcode <= ALU;
						endcase // inst[11:8]
					end
					2'b01:begin	// Load, Store, SYSTEM CALL or Conditional Execution
						case (inst[11:10])
							2'b00: 	opcode <= LOAD;
							2'b01: 	opcode <= STORE;
							2'b10: 	opcode <= SYSTEM_CALL;
							2'b11: 	opcode <= CONDITIONAL_EXEC;
						endcase // inst[12:10]
					end
					2'b10, 2'b11: 	opcode <= MOVE_IMMEDIATE;
				endcase // inst[13:12]
			end
			2'b10: 					opcode <= LOAD_RELATIVE;
			2'b11: 					opcode <= STORE_RELATIVE;
		endcase // inst[15:14]

		// General Signals decoding
		byte_inst <= inst[6];
		dst_reg <= inst[2:0];
		src_reg <= inst[5:3];

		// ALU & Shift instruction sginals decoding
		// Shifter re-uses the ALU operation signal
		alu_wb <= 1;
		update_status <= 1;
		Reg_or_Const <= inst[7];

		case (inst[11:7]) inside
            5'b0000?: 				// inst. ADD
                ALU_op <= ADD;
            5'b0001?:               // inst. ADDC
                ALU_op <= ADDC;
            5'b0010?:     			// inst. SUB
                ALU_op <= SUB;
            5'b0101?: begin    		// inst. CMP
                ALU_op <= SUB;
                alu_wb <= 0;
            end
            5'b0011?:               // inst. SUBC
                ALU_op <= SUBC;
            5'b0100?: begin			// inst. DADD
            	ALU_op <= ADD;
            	alu_wb <= 0;
            	update_status <= 0;
            end
            5'b0110?:               // inst. XOR
                ALU_op <= XOR;
            5'b0111?:				// inst. AND
                ALU_op <= AND;
            5'b1000?: begin			// inst. BIT
            	ALU_op <= AND;
        		alu_wb <= 0;
            end
            5'b1001?:               // inst. BIC
                ALU_op <= BIC;
            5'b1010?:               // inst. BIS
                ALU_op <= BIS;
            5'b1011?: begin 		// inst. MOV
                ALU_op <= PASS_B;
                update_status <= 0;
            end
            5'b1101?:               // inst. SRA
                ALU_op <= SRA;
            5'b1110?:               // inst. RRC
                ALU_op <= RRC;
            5'b11110: begin         // inst. SWPB
                ALU_op <= SWPB;
                update_status <= 0;
            end
            5'b11111: begin         // inst. SXT
                ALU_op <= SXT;
                update_status <= 0;
            end
            default: begin
            	ALU_op <= PASS_B;
                update_status <= 0;
                alu_wb <= 0;
            end
        endcase

        // Branch instruction signals decoding
        if (inst[13]) begin	// Branch Conditional
	        branch_offset <= {{5{inst[9]}}, inst[9:0], 1'b0};
	    	branch_cond <= inst[12:10];
	    end
        else begin			// Branch with Link
	        branch_offset <= {{2{inst[12]}}, inst[12:0], 1'b0};
	    	branch_cond <= 3'b111;	// Always branch
	    end

	    // Load & Store instruction signals decoding
	    addr_PREPO 	<= inst[9];
	    addr_DEC 	<= inst[8];
	    addr_INC 	<= inst[7];

	    // Load and Store Relative instruction signals decoding
	    mem_offset <= {{9{inst[13]}}, inst[13:7]};

	    // Move Immendiate instruction signals decoding
	    imm_val[7:0] <= inst[10:3];

	    case (inst[12:11])
        2'b00: begin	// MOVL
        	imm_wb  <= 2'b01;
        	imm_val[15:8] <= inst[10:3];
    	end
        2'b01: begin	// MOVlZ
        	imm_wb  <= 2'b11;
        	imm_val[15:8] <= 8'h0;
    	end
        2'b10: begin	// MOVLS
        	imm_wb  <= 2'b11;
        	imm_val[15:8] <= 8'hFF;
    	end
        2'b11: begin	// MOVH
        	imm_wb  <= 2'b10;
        	imm_val[15:8] <= inst[10:3];
    	end
        endcase // inst[12:11]
	end

endmodule : instruction_decoder