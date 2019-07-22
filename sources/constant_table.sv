`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/19/2019 09:18:09 PM
// Design Name: 
// Module Name: constant_table_m
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


module constant_table_m
#(
	parameter WORD_SIZE = 16
 )
(
    input wire [2:0] addr,
    output wire [WORD_SIZE-1:0] data
);

    reg [WORD_SIZE-1:0] ConstantTable[7:0] = {0, 1, 2, 4, 8, 32, 48, -1};
    
    assign data = ConstantTable[addr];
endmodule
