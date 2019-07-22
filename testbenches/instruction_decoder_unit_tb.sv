`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/17/2019 11:25:02 AM
// Design Name: 
// Module Name: instruction_decoder_unit_tb
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


module instruction_decoder_unit_tb();
    
    reg clk, reset, en;
    reg[15:0] inst_data;
    reg byte_inst, src_op_type, alu_no_wb;
    reg[1:0] alu_block_sel, alu_block_func, imm_mov_wb;
    reg[2:0] dst_op, src_op, branch_cond;
    reg[2:0] operation;
    reg[15:0] imm_val, addr_offset, branch_offset;
    
    instruction_decoder_unit_m decoder(.*);
    
    initial begin
        clk <= 0;
        reset <= 0;
        inst_data <= 0;
    end
    
    always begin
        #5 clk <= ~clk;
    end
    
    initial begin
        en <= 1;
        
    #5 inst_data  <= 'b0100001001010100; // sub.b R2,R4 (block = 0, func = 1, op = 2)
    #10 inst_data <= 'b0001111111111110; // BL #-2 (op = 0)
    #10 inst_data <= 'b0100010100001000; // cmp R1,R0 (block = 0, func = 1, op = 2, no_wb SET)
    #10 inst_data <= 'b1101111100011101; // STR R3,R5,#62, (op = 4, offset = 62) 
    #10 inst_data <= 'b0111010101010000; // MOVLS #252,R0 (op = 7, value = $FFAA)
    #10 inst_data <= 'b0100110100000001; // SRA R1 (block = 2, func = 0, op = 2)
    #10 inst_data <= 'b0100111110000111; // SXT R7 (block = 3, func = 2, op = 2)
    #10 inst_data <= 'b0100011010010100; // XOR #2,R4 (block = 1, func = 0, op = 2)
    
    end
    
endmodule
