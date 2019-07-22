`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/30/2019 01:57:03 AM
// Design Name: 
// Module Name: manipulation-block
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

//module manipulation_block_mi
//(
//    ALU_block_io intf
//);

//    manipulation_block_m move_block(
//        .src_a(intf.src_a), 
//        .src_b(intf.src_b),
//        .func({intf.byte_op, intf.func}),
//        .result(intf.result),
//        .carry(intf.carry), 
//        .ovf(intf.ovf)
//    );
    
//endmodule 

module manipulation_block_m
#(
    parameter WORD_SIZE = 16
 )
(
    input wire[1:0] func,
    input wire[WORD_SIZE-1:0] src_a, src_b,
    output reg[WORD_SIZE-1:0] result
);

    localparam HALF_WORD = WORD_SIZE/2;

    enum {MOV, SWPB, SXT} MANIPULATION_BLOCK_FUNCTIONS;

    always @ (*) 
    begin
        case (func)
            MOV:
                result <= src_b;
            SWPB:
                result <= {src_a[HALF_WORD-1:0], src_a[WORD_SIZE-1:HALF_WORD]};
            SXT:
                result <= {{HALF_WORD{src_a[HALF_WORD-1]}}, src_a[HALF_WORD-1:0]};
            default:
                result <= src_b;
        endcase
    end
endmodule
