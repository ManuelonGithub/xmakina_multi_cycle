`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/31/2019 10:37:50 PM
// Design Name: 
// Module Name: ALU-tb
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


module ALU_tb();

    localparam ARRITHMETIC_DELAY = 0;
    localparam LOGIC_DELAY = 50;
    localparam SHIFTER_DELAY = 100;
    localparam MOVE_DELAY = 150;

    reg [1:0] block_sel = 0, block_func = 0;
    reg carry_in = 0, byte_op = 0;
    
    reg [15:0] src_a = 0, src_b = 0;
    
    reg [15:0] result;
    reg carry, zero, neg, ovf;
    
    ALU ALU_test(.*);
    
    initial ARRITHMETIC_TESTING: 
    begin
        #ARRITHMETIC_DELAY
            block_sel <= 0;
        #5  // [5] Addition: Result = hFE, no flags
            src_a <= 'h7f;
            src_b <= 'h7f;
        #5  // [10] Subtraction: Result = 0, ZERO & CARRY
            block_func[1] <= 1; 
        #5  // [15] Byte Addition: Result = hFE, OVF
            block_func[1] <= 0;
            byte_op <= 1;
        #5  // [20] Full word addition: Result = hFF01, CARRY & NEG
            src_a <= 'hff80;
            src_b <= 'hff81;
            byte_op <= 0;
        #5  // [25] Byte addition: Result = h01, CARRY & OVF
            byte_op <= 1;
        #5  // [30] Addition with carry: Result = h02, CARRY & OVF
            carry_in <= 1;
            block_func[0] <= 1;
            byte_op <= 1;
        #5 // [35]
            src_a <= 0;
            src_b <= 0;
            carry_in <= 0;
            byte_op <= 0;
            block_func <= 0;
    end

    initial LOGIC_TESTING: 
    begin
        #LOGIC_DELAY
            block_sel <= 1;
        #5  // XOR: Result = hFF0F, 
            src_a <= 'h66AA;
            src_b <= 'h99A5;
        #5  // AND: Result = hA0,
            block_func <= 1; 
        #5  // BIC: Result = hAAAA, 
            src_a <= 'hFFFF;
            src_b <= 'h5555;
            block_func <= 2;
        #5  // BIS: Result = hFFFF, 
            src_a <= 'hAAAA;
            src_b <= 'h5555;
            block_func <= 3;
        #5  // AND byte operation: Result = FF80,
            src_a <= 'h00EF;
            src_b <= 'hFF80;
            block_func <= 1;
            byte_op <= 1;
        #5  // XOR byte operation: Result = h0000, 
            src_a <= 'h00AA;
            src_b <= 'hFF55;
            block_func <= 0;
        #5
            src_a <= 0;
            src_b <= 0;
            carry_in <= 0;
            byte_op <= 0;
            block_func <= 0;
    end

    initial SHIFTER_TESTING: 
    begin
        #SHIFTER_DELAY
            block_sel <= 2;
        #5  // SRA: Result = h3FFF, 
            src_a <= 'h7FFF;
        #5  // SRAB: Result = hFFF7,
            src_a <= 'h00EF;
            byte_op <= 1;
        #5  // RRC: Result = h8000, 
            src_a <= 'h0001;
            carry_in <= 1;
            block_func <= 1;
            byte_op <= 0;
        #5  // RRCB: Result = hF80, 
            byte_op <= 1;
        #5  // SXT, Result = hFFAA;
            src_a <= 'h00AA;
            block_func <= 2;
        #5
            src_a <= 0;
            src_b <= 0;
            carry_in <= 0;
            byte_op <= 0;
            block_func <= 0;
    end
    
    initial MOVER_TESTING: 
    begin
        #MOVE_DELAY
            block_sel <= 3;
        #5  // MOV: result = hAAAA
            src_b <= 'hAAAA;
        #5  // MOVZ: result = h00AA
            block_func <= 1;
        #5  // MOVS: result = hFFAA
            block_func <= 2;
        #5
            src_a <= 0;
            src_b <= 0;
            carry_in <= 0;
            byte_op <= 0;
            block_func <= 0;
    end

endmodule
