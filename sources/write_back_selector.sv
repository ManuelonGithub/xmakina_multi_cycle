`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/19/2019 09:18:09 PM
// Design Name: 
// Module Name: write_back_selector
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


module write_back_selector
#(
	parameter WORD_SIZE = 16
 )
(
	input wire mem_wr, pc_wr,
	input wire[WORD_SIZE-1:0] alu_in, mem_in, pc_in,
	output reg[WORD_SIZE-1:0] data_out
);

	always @ (*) begin
		case (1'b1) 
			mem_wr:
				data_out <= mem_in;
			pc_wr:
				data_out <= pc_in;
			default:
				data_out <= alu_in;
		endcase
	end

endmodule
