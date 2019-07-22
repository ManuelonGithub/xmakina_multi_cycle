`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/30/2019 01:57:03 AM
// Design Name: 
// Module Name: arrithmetic-block
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

//module arrithmetic_block_mi
//(
//    ALU_block_io intf
//);

//    arrithmetic_block_m arrithmetic_block (
//        .src_a(intf.src_a), 
//        .src_b(intf.src_b),
//        .byte_op(intf.byte_op),
//        .sub_op(intf.func[1]), 
//        .carry_op(intf.func[0]), 
//        .carry_in(intf.carry_in), 
//        .result(intf.result),
//        .carry(intf.carry), 
//        .ovf(intf.ovf)
//    );

//endmodule

module arrithmetic_block_m
#(
    parameter WORD_SIZE = 16
 )
(
    input wire byte_op, sub_op, carry_op, carry_in,
    input wire[WORD_SIZE-1:0] src_a, src_b,
    output reg carry, ovf,
    output reg[WORD_SIZE-1:0] result
);

    localparam HALF_WORD = WORD_SIZE/2;
    
    enum {WORD_RES, BYTE_RES} RESULT_TYPE;

    wire[WORD_SIZE-1:0] op_src_b = src_b ^ {WORD_SIZE{sub_op}};
    
    wire h_cout[0:1];
    wire h_cin[0:1] = {(carry_in & carry_op) ^ sub_op, h_cout[0]};
    
    wire h_ovf[0:1];
    
    wire[HALF_WORD-1:0] h_src_a [0:1] = 
        {src_a[HALF_WORD-1:0], src_a[WORD_SIZE-1:HALF_WORD]};
        
    wire[HALF_WORD-1:0] h_src_b [0:1] = 
        {op_src_b[HALF_WORD-1:0], op_src_b[WORD_SIZE-1:HALF_WORD]};
    
    wire[HALF_WORD-1:0] h_res [0:1];
    wire[WORD_SIZE-1:0] res = {h_res[1], h_res[0]};
    
    adder_overflow_m #(HALF_WORD) half_adder[2] 
    (
        .src_a(h_src_a), 
        .src_b(h_src_b), 
        .c_in(h_cin),
        .result(h_res), 
        .carry(h_cout), 
        .ovf(h_ovf)
    );
    
    always @ (*) 
    begin
        result <= res;
        carry <= h_cout[byte_op];
        ovf <= h_ovf[byte_op];
    end
    
endmodule

module adder_overflow_m
#(parameter OP_WIDTH = 16)
(
    input wire [OP_WIDTH-1:0] src_a, src_b,
    input wire c_in,
    output reg [OP_WIDTH-1:0] result,
    output reg carry, ovf
);

    reg [OP_WIDTH-1:0] partial_sum;
    wire c_sign = partial_sum[OP_WIDTH-1], a_x_b = src_a[OP_WIDTH-1] ^ src_b[OP_WIDTH-1];
    
    always @ (*) 
    begin
        partial_sum <= src_a[OP_WIDTH-2:0] + src_b[OP_WIDTH-2:0] + c_in;
        
        result[OP_WIDTH-2:0] <= partial_sum;
        result[OP_WIDTH-1] <= a_x_b ^ c_sign;
        
        carry <= (a_x_b & c_sign) | (src_a[OP_WIDTH-1] & src_b[OP_WIDTH-1]);
        ovf <= c_sign ^ carry;
    end

endmodule