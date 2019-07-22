`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/30/2019 01:57:03 AM
// Design Name: 
// Module Name: logic-block
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

//module logic_block_mi
//(
//    ALU_block_io intf
//);

//    logic_block_m logic_block(
//        .src_a(intf.src_a), 
//        .src_b(intf.src_b), 
//        .func({intf.byte_op, intf.func}),
//        .result(intf.result),
//        .carry(intf.carry), 
//        .ovf(intf.ovf)
//    );

//endmodule

module logic_block_m
#(
    parameter WORD_SIZE = 16
 )
(
    input wire [WORD_SIZE-1:0] src_a, src_b,
    input wire [1:0] func,
    output reg [WORD_SIZE-1:0] result
);

    enum {XOR, AND, BIC, BIS, LOGIC_FUNCTIONS}  LOGIC_BLOCK_FUNCTIONS;

    always @ (*)
    begin
        case (func)
            XOR:
                result <= src_a ^ src_b;
            AND:
                result <= src_a & src_b;
            BIC:
                result <= src_a & ~src_b;
            BIS:
                result <= src_a | src_b;
        endcase
    end

endmodule
