`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/18/2019 01:54:41 AM
// Design Name: 
// Module Name: execution_unit_m
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


module execution_unit_m
#( parameter DEBUG = 0)
(
    input wire clk, reset, // "External" inputs
    input wire fetch_done, // Fetch unit input
    input wire[1:0] reg_wb,                 // Decode Unit inputs
    input wire[2:0] branch_cond, macro_op,  //          "
    
    output reg[9:0] exec_state_reg,

    output reg fetch_en, // Fetch Unit control signal
    output reg pc_fetch_wr, // PC control signals
    output reg decode_en, // Decoder Unit control signals
    output reg alu_in_en, alu_out_en,
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
        INC_PC,
        DECODE,
        OPERAND_FETCH,
        ALU_EXECUTE,
        BRANCH_EXECUTE,
        NOP_EXECUTE,
        MEMORY_ACCESS,
        WRITE_BACK
    } EXECUTION_STATES;

    reg[9:0] state;
    // Memory access takes 2 clock cycles! 
    
    initial begin
        fetch_en <= 0;
        pc_fetch_wr <= 0;
        decode_en <= 0;
        reg_wr_en <= 0;
        alu_in_en <= 0;
        alu_out_en <= 0;
        state <= (1 << INIT);
    end

    always @ (*) begin
        if (DEBUG) begin
            exec_state_reg <= state;
        end
        else
            exec_state_reg <= 0;
    end

    always @ (posedge clk) begin : CAPTURE_AND_PROCESS
        case (1'b1) 
            state[INIT]:
                state <= (1 << FETCH);
            
            state[FETCH]:
                state <= (1 << INC_PC);
            
            state[INC_PC]:
                state <= (1 << DECODE);
            
            state[DECODE]: begin
                if (fetch_done)
                    state <= (1 << OPERAND_FETCH);
                else
                    state <= (1 << DECODE);
            end

            state[OPERAND_FETCH]: begin
                // Branch condition stuff may be done here 
                // Memory access stuff as well
                case (macro_op)
                    SYSTEM_CALL, CONDITIONAL_EXEC:
                        state <= (1 << NOP_EXECUTE);
                    default:
                        state <= (1 << ALU_EXECUTE);
                endcase
            end

            state[ALU_EXECUTE]: begin
                case (macro_op)
                    LOAD, STORE:
                        state <= (1 << MEMORY_ACCESS);
                    default:
                        state <= (1 << WRITE_BACK);
                endcase
            end

            state[NOP_EXECUTE], state[WRITE_BACK]:
                state <= (1 << FETCH);
        endcase
    end
    
    always @ (negedge clk) begin : SIGNAL_DRIVING
        case (1'b1) 
            state[INIT]: begin
            end
            
            state[FETCH]: begin
                reg_wr_en <= 0;
                fetch_en <= 1;
            end
            
            state[INC_PC]: begin
                fetch_en <= 0;
                pc_fetch_wr <= 1;
            end
            
            state[DECODE]: begin
                pc_fetch_wr <= 0;
                decode_en <= fetch_done;
            end

            state[OPERAND_FETCH]: begin
                decode_en <= 0;
                alu_in_en <= 1;
                // ALU source registers might be implemented,
                // If so here their enable signals need to be asserted.
            end
            state[ALU_EXECUTE]: begin
                alu_in_en <= 0;
                alu_out_en <= 1;
                // If/when the ALU source registers get implemented,
                // Their enable signals get de-asserted here.
                // PSW enable needs to be done here (if needed)
                // Decode unit will probably make the decision on whether or not
                // PSW gets updated.
                // So here all that is needed to be done is PSW <= PSW_en (no logic check).
            end

            state[MEMORY_ACCESS]: begin
                alu_out_en <= 0;
                // Here all memory signals are outputted.
                // Fetch Operand state determined their values,
                // Here we are just outputting all.
            end

            state[WRITE_BACK]: begin
                alu_out_en <= 0;
                reg_wr_en <= reg_wb;
            end
        endcase
    end

endmodule
