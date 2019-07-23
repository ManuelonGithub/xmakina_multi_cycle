`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/18/2019 01:54:41 AM
// Design Name: 
// Module Name: control_unit
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


module control_unit
#( parameter DEBUG = 0)
(
    input wire clk, reset, // "External" inputs

    input wire      fetch_done,             // Fetch unit input

    input wire      branch_en, new_status_en, // Decode Unit inputs
    input wire[1:0] reg_wb_mode,              //          "
    input wire[2:0] branch_cond, macro_op,    //          "

    // input wire mem_rd_done,
    input wire[15:0] status_reg,

    output reg[9:0] exec_state_reg,

    output reg fetch_en, // Fetch Unit control signal
    output reg pc_fetch_wr, pc_branch_wr, // PC control signals
    output reg decode_en, // Decoder Unit control signals
    output reg alu_in_en, alu_out_en,
    output reg status_wr,
    output reg[1:0] reg_wr_en
);

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

    typedef enum logic[3:0] {
        INIT,
        FETCH,
        WAIT_FETCH,
        DECODE,
        OPERAND_FETCH,
        EXECUTE,
        NOP_EXECUTE,
        MEMORY_ACCESS,
        WRITE_BACK
    } EXECUTION_STATES;

    enum {C, Z, N, V} STATUS_BITS;

    reg[9:0] state;
    // Memory access takes 2 clock cycles! 

    wire[3:0] status_bits = status_reg[V:C];
    reg branch_cond_res;

    branch_logic_block branch_logic (
        .status     (status_bits),
        .branch_cond(branch_cond),
        .result     (branch_cond_res)
    );
    
    initial begin
        fetch_en <= 0;
        pc_fetch_wr <= 0;
        pc_branch_wr <= 0;
        decode_en <= 0;
        alu_in_en <= 0;
        alu_out_en <= 0;
        status_wr <= 0;
        reg_wr_en <= 0;
        state <= (1 << INIT);
    end

    always @ (*) begin
        if (DEBUG) begin
            exec_state_reg <= state;
        end
        else
            exec_state_reg <= 0;
    end

    /*
    always @ (posedge clk) begin : CAPTURE_AND_PROCESS
        case (1'b1) 
            state[INIT]: begin
                do_fetch <= 1;
                state <= (1 << FETCH);
            end
            
            state[FETCH]: begin
                do_fetch <= 0;
                state <= (1 << WAIT_FETCH);
            end

            state[WAIT_FETCH]: begin
                if (fetch_done)
                    state <= (1 << DECODE);
                else
                    state <= (1 << WAIT_FETCH);
            end
            
            state[DECODE]: begin
                state <= (1 << OPERAND_FETCH);
            end

            state[OPERAND_FETCH]: begin
                // Branch condition stuff may be done here 
                // Memory access stuff as well

                case (macro_op)
                    SYSTEM_CALL, CONDITIONAL_EXEC:
                        state <= (1 << NOP_EXECUTE);
                    default:
                        state <= (1 << EXECUTE);
                endcase
            end

            state[EXECUTE]: begin
                case (macro_op)
                    LOAD, STORE:
                        state <= (1 << MEMORY_ACCESS);
                    default:
                        state <= (1 << WRITE_BACK);
                endcase
            end

            state[NOP_EXECUTE], state[WRITE_BACK]:
                state <= (1 << FETCH);

            state[MEMORY_ACCESS]: begin
                rd_mem <= 0;

            end
        endcase
    end
    */
    
    always @ (negedge clk) begin : STATE_MACHINE
        case (1'b1) 
            state[INIT]: begin
                state <= (1 << FETCH);

                fetch_en <= 1;
            end
            
            state[FETCH]: begin
                state <= (1 << WAIT_FETCH);

                fetch_en <= 0;
            end
            
            state[WAIT_FETCH]: begin
                if (fetch_done) begin
                    state <= (1 << DECODE);

                    pc_fetch_wr <= 1;
                    decode_en <= 1;
                end
                else
                state <= (1 << WAIT_FETCH);
            end
            
            state[DECODE]: begin
                state <= (1 << OPERAND_FETCH);         

                pc_fetch_wr <= 0;
                decode_en <= 0;
                alu_in_en <= 1;
            end

            state[OPERAND_FETCH]: begin
                case (macro_op)
                    SYSTEM_CALL, CONDITIONAL_EXEC:
                        state <= (1 << NOP_EXECUTE);
                    default: begin
                        state <= (1 << EXECUTE);
                    end
                endcase

                alu_in_en <= 0;
                alu_out_en <= 1;

                if (branch_en)
                    pc_branch_wr <= branch_cond_res;

                // PSW enable needs to be done here (if needed)
                // Decode unit will probably make the decision on whether or not
                // PSW gets updated.
                // So here all that is needed to be done is PSW <= PSW_en (no logic check).
            end

            state[EXECUTE]: begin
                case (macro_op)
                    LOAD, STORE: begin
                        state <= (1 << MEMORY_ACCESS);

                        // Here all memory signals are outputted.
                        // Fetch Operand state determined their values,
                        // Here we are just outputting all.
                    end
                    default: begin
                        state <= (1 << WRITE_BACK);

                        reg_wr_en <= reg_wb_mode;
                    end
                endcase

                alu_out_en <= 0;
                pc_branch_wr <= 0;

                status_wr <= new_status_en;
            end

            

            state[MEMORY_ACCESS]: begin
                state <= (1 << FETCH);

                reg_wr_en <= reg_wb_mode;
            end

            state[WRITE_BACK]: begin
                state <= (1 << FETCH);

                status_wr <= 0;
                reg_wr_en <= 0;
                fetch_en <= 1;
            end
        endcase
    end

endmodule
