`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/21/2019 06:13:35 PM
// Design Name: 
// Module Name: cpu_debug
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

package debug;
	const int WORD_SIZE = 16;
	const int HALF_WORD = WORD_SIZE/2;

    const int MAX_MEM_DEPTH = 32768;

    typedef enum logic[1:0] {
        ARRITHMETIC, 
        BOOLEAN_LOGIC, 
        SHIFTER, 
        MANIPULATION
    } ALU_BLOCKS;

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

    typedef enum logic[2:0] {
        BRANCH_W_LINK, 
        CONDITIONAL_BRANCH, 
        ALU_OPERATION,
        LOAD,
        STORE,
        SYSTEM_CALL,
        CONDITIONAL_EXEC,
        IMMEDIATE_MOVE
    } MACRO_OPERATIONS;

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
		ADDR_OFFSET
	} OPERANDS;

	typedef enum logic[1:0] {
		NO_WRITE,
		LOW_BYTE,
		HIGH_BYTE,
		WORD
	} REG_WRITE_MODE;

    typedef struct packed {
        logic[15:0] R0, R1, R2, R3, R4, R5, R6, R7;
    } reg_file_t;

    typedef enum logic[1:0] {C, Z, N, V} STATUS_BITS;

    typedef struct packed {
        logic C, Z, N, V;
    } status_t;

	typedef struct packed {
		logic fetch_en, pc_fetch_wr, decode_en, alu_in_en, alu_out_en;
        logic fetch_done, pc_branch_wr, status_wr;
        logic[15:0] alu_in_a, alu_in_b, alu_out;
        reg_file_t reg_file;
        status_t status;
        EXECUTION_STATES exec_state;
        REG_WRITE_MODE reg_wr;
		MACRO_OPERATIONS macro_op;
        BRANCH_CONDITIONS branch_cond;
		ALU_FUNCTIONS alu_func;
		OPERANDS alu_a_org, alu_b_org, dst_reg;
	} debug_signals_t;
endpackage


import debug::*;

module cpu_debug_module
(
	input wire fetch_en, pc_fetch_wr, decode_en, alu_in_en, alu_out_en,
    input wire fetch_done, status_wr, pc_branch_wr, 
    input wire[1:0] reg_wr_en,
    input wire[2:0] macro_op, src_select, reg_src_a, reg_src_b, dst_reg,
    input wire[2:0] branch_cond,
    input wire[3:0] alu_func, status,
    input wire[9:0] exec_state_reg,
	input wire[15:0] alu_in_a, alu_in_b, alu_out, reg_file[0:7],
	output debug_signals_t debug_out
);

	always @ (*) begin
		debug_out.fetch_en    <= fetch_en;
		debug_out.pc_fetch_wr <= pc_fetch_wr;
		debug_out.decode_en   <= decode_en;
		debug_out.alu_in_en   <= alu_in_en;
		debug_out.alu_out_en  <= alu_out_en;
        debug_out.fetch_done  <= fetch_done;
		debug_out.alu_in_a    <= alu_in_a;
		debug_out.alu_in_b    <= alu_in_b;
		debug_out.alu_out     <= alu_out;
		debug_out.reg_file    <= {>>{reg_file}};
        debug_out.pc_branch_wr <= pc_branch_wr;
        debug_out.status_wr <= status_wr;
        debug_out.status <= status;

		debug_out.macro_op  <= MACRO_OPERATIONS'(macro_op);
		debug_out.alu_func  <= ALU_FUNCTIONS'(alu_func);
		debug_out.alu_a_org <= OPERANDS'(reg_src_a);
		debug_out.dst_reg   <= OPERANDS'(dst_reg);
		debug_out.reg_wr    <= REG_WRITE_MODE'(reg_wr_en);
        debug_out.branch_cond <= BRANCH_CONDITIONS'(branch_cond);

        case (1'b1) 
            exec_state_reg[INIT]:
                debug_out.exec_state <= INIT;
            exec_state_reg[FETCH]:
                debug_out.exec_state <= FETCH;
            exec_state_reg[WAIT_FETCH]:
                debug_out.exec_state <= WAIT_FETCH;
            exec_state_reg[DECODE]:
                debug_out.exec_state <= DECODE;
            exec_state_reg[OPERAND_FETCH]:
                debug_out.exec_state <= OPERAND_FETCH;
            exec_state_reg[EXECUTE]:
                debug_out.exec_state <= EXECUTE;
            exec_state_reg[MEMORY_ACCESS]:
                debug_out.exec_state <= MEMORY_ACCESS;
            exec_state_reg[WRITE_BACK]:
                debug_out.exec_state <= WRITE_BACK;
            default:
            	debug_out.exec_state <= INIT;
        endcase

        case (1'b1)
        	src_select[0]:
        		debug_out.alu_b_org <= OPERANDS'({1'b1,reg_src_b});
        	src_select[1]:
        		debug_out.alu_b_org <= IMM_VAL;
        	src_select[2]:
        		debug_out.alu_b_org <= ADDR_OFFSET;
    		default:
        		debug_out.alu_b_org <= OPERANDS'(reg_src_b);

        endcase
	end

endmodule