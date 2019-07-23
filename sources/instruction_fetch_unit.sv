`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/19/2019 08:03:47 PM
// Design Name: 
// Module Name: instruction_fetch_unit
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


module instruction_fetch_unit
#(
    parameter WORD_SIZE = 16
 )
(
    input wire en, 
    input wire[WORD_SIZE-1:0] PC_in, 
    
    input wire mem_err, mem_done,
    input wire[WORD_SIZE-1:0] mem_data,
    
    output reg mem_en, mem_access_size,
    output reg[WORD_SIZE-1:0] mem_addr,
    
    output reg fetch_err, int_ret, fetch_done,
    output reg[WORD_SIZE-1:0] fetch_data
);
    
    always @ (*) 
    begin
        int_ret <= (PC_in == {WORD_SIZE{1'b1}});
        
        mem_en <= (en & ~int_ret);
        mem_addr <= PC_in;
        mem_access_size <= 1;
        
        fetch_err <= mem_err;
        fetch_done <= mem_done;
        fetch_data <= mem_data;
    end

endmodule
