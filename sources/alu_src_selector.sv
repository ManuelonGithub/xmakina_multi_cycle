`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/19/2019 09:18:09 PM
// Design Name: 
// Module Name: alu_src_selector_m
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


module alu_src_selector_m
#(
	parameter WORD_SIZE = 16
 )
(
	input wire const_sel, imm_val_sel, offset_sel,
	input wire[WORD_SIZE-1:0] reg_file_in, const_in, imm_val_in, offset_in,
	output reg[WORD_SIZE-1:0] src_out
);

	always @ (*) begin
		case (1'b1) 
			const_sel:
				src_out <= const_in;
			imm_val_sel:
				src_out <= imm_val_in;
			offset_sel:
				src_out <= offset_in;
			default:
				src_out <= reg_file_in;
		endcase
	end

endmodule
