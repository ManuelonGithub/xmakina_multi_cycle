`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/01/2019 02:11:56 AM
// Design Name: 
// Module Name: program_counter_unit
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


module program_counter_unit
#(
    parameter REG_WIDTH = 16
 )
(
    input wire clk, fetch_en, branch_en,
    input wire[1:0] reg_wr_en,
    input wire[REG_WIDTH-1:0] reg_in, branch_offset,
    output reg[REG_WIDTH-1:0] PC_out
);
    
    localparam H_WIDTH = REG_WIDTH/2;
    
    reg[REG_WIDTH-1:0] PC_reg;

    wire[REG_WIDTH-1:0] fetch_pc = PC_reg + (REG_WIDTH/8);
    wire[REG_WIDTH-1:0] branch_pc = PC_reg + branch_offset;
    
    wire reg_en = |reg_wr_en;
    
    initial begin
        PC_reg <= 0;
    end
    
    always @ (posedge clk) begin
        case (1'b1) 
            reg_en: begin
                if (reg_wr_en[0])
                    PC_reg[H_WIDTH-1:0] <=  reg_in[H_WIDTH-1:0];
                if (reg_wr_en[1])
                    PC_reg[REG_WIDTH-1:H_WIDTH] <=  reg_in[REG_WIDTH-1:H_WIDTH];
            end
            
            fetch_en:
                PC_reg <= fetch_pc;
                
            branch_en:
                PC_reg <= branch_pc;
        endcase
    end
    
    always @ (*) begin
        PC_out <= PC_reg;
    end
    
endmodule

