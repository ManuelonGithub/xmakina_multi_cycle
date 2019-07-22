`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/01/2019 02:11:56 AM
// Design Name: 
// Module Name: program_counter_m
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


module program_counter_m
#(
    parameter REG_WIDTH = 16
 )
(
    input wire clk, fetch_en, branch_en,
    input wire[1:0] reg_wr_en,
    input wire[REG_WIDTH-1:0] reg_in, fetch_in, branch_in,
    output reg[REG_WIDTH-1:0] PC_out
);
    
    localparam HALF_WORD = REG_WIDTH/2;
    
    reg[REG_WIDTH-1:0] PC_reg;
    
    wire reg_en = |reg_wr_en;
    
    initial begin
        PC_reg <= 0;
    end
    
    always @ (posedge clk) begin
        case (1'b1) 
            reg_en: begin
                if (reg_wr_en[0])
                    PC_reg[HALF_WORD-1:0] <=  reg_in[HALF_WORD-1:0];
                if (reg_wr_en[1])
                    PC_reg[REG_WIDTH-1:HALF_WORD] <=  reg_in[REG_WIDTH-1:HALF_WORD];
            end
            
            fetch_en:
                PC_reg <= fetch_in;
                
            branch_en:
                PC_reg <= branch_in;
        endcase
    end
    
    always @ (*) begin
        PC_out <= PC_reg;
    end
    
endmodule

