`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/16/2019 06:46:04 PM
// Design Name: 
// Module Name: memory_m
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


module memory_m
#(
    parameter COL_WIDTH = 8,
    parameter COL_NB = 2,
    parameter MEM_DEPTH = 32768,
    parameter RD_SRC_NB = 2,

    parameter MEM_FILE = "test_mem_0.mem",
    parameter USE_MEM_FILE = 0
 )
(
    input wire clk, rd_en[0:(RD_SRC_NB-1)],
    input wire[COL_NB-1:0] wr_en,
    input wire[(COL_WIDTH*COL_NB)-1:0] wr_data,
    input wire[$clog2(MEM_DEPTH-1)-1:0] wr_addr, rd_addr[0:(RD_SRC_NB-1)],
    output reg wr_done, rd_done[0:(RD_SRC_NB-1)],
    output reg[(COL_WIDTH*COL_NB)-1:0] rd_data[0:(RD_SRC_NB-1)]
);
    
    reg [(COL_WIDTH*COL_NB)-1:0] memory[0:(MEM_DEPTH-1)];
    
    initial begin
        wr_done <= 0;
    
        for (int i = 0; i < MEM_DEPTH; i++)  begin
            memory[i] = 'hFFFF;
        end

        if (USE_MEM_FILE)
            $readmemb(MEM_FILE,memory);
        
        for (int init = 0; init < RD_SRC_NB; init = init + 1) begin
            rd_data[init] <= 'h0;
            rd_done[init] <= 'h0;
        end
    end
    
    generate
    genvar rd_i;
        for (rd_i = 0; rd_i < RD_SRC_NB; rd_i = rd_i + 1) begin
            always @ (negedge clk) begin
                if (rd_en[rd_i]) begin
                    rd_data[rd_i] <= memory[rd_addr[rd_i]];
                    rd_done[rd_i] <= 1;
                end
                else
                    rd_done[rd_i] <= 0;
            end
        end
    endgenerate

    generate
    genvar wr_i;
        for (wr_i = 0; wr_i < COL_NB; wr_i = wr_i + 1) begin
            always @ (negedge clk) begin
                if (wr_en[wr_i]) begin
                    memory[wr_addr][((COL_WIDTH+COL_WIDTH*wr_i)-1):(COL_WIDTH*wr_i)] 
                        <= wr_data[((COL_WIDTH+COL_WIDTH*wr_i)-1):(COL_WIDTH*wr_i)];
                    
                    wr_done <= 1;
                end
                else
                    wr_done <= 0;
            end
        end
    endgenerate

endmodule
