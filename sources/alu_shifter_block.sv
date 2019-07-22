`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/30/2019 01:57:03 AM
// Design Name: 
// Module Name: shifter-block
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

//module shifter_block_mi
//(
//    ALU_block_io intf
//);

//    shifter_block_m shifter_block(
//        .src(intf.src_a), 
//        .func({intf.byte_op, intf.func}),
//        .carry_in(intf.carry_in),
//        .result(intf.result),
//        .carry(intf.carry), 
//        .ovf(intf.ovf)
//    );

//endmodule

module shifter_block_m
#(
    parameter WORD_SIZE = 16
 )
(
    input wire feed_in,
    input wire [1:0] func,
    input wire [WORD_SIZE-1:0] src,
    output reg feed_out,
    output reg [WORD_SIZE-1:0] result
);

    localparam HALF_WORD = WORD_SIZE/2;    

    enum {SRA, RRC, SRAB, RRCB} SHIFTER_BLOCK_funcTIONS;
    
    always @ (*) 
    begin  
        case (func)
            SRA:
                result <= {src[WORD_SIZE-1], src[WORD_SIZE-1:1]};
            RRC:
                result <= {feed_in, src[WORD_SIZE-1:1]};
            SRAB:
                result <= {{(HALF_WORD+1){src[HALF_WORD-1]}}, src[HALF_WORD-1:1]};
            RRCB:
                result <= {{(HALF_WORD+1){feed_in}}, src[HALF_WORD-1:1]};
            default:
                result <= {src[WORD_SIZE-1], src[WORD_SIZE-1:1]};
        endcase
        
        feed_out <= src[0];
    end

endmodule
