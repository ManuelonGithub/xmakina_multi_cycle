`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/19/2019 03:46:43 PM
// Design Name: 
// Module Name: memory_controller_m
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


module memory_controller_m
#(
    parameter MEM_DEPTH = 32768,
    parameter WORD_SIZE = 16,
    parameter RD_CHANNELS = 2
 )
(
    input wire clk, reset, wr_en, wr_size, rd_en[0:(RD_CHANNELS-1)], rd_size[0:(RD_CHANNELS-1)], 
    input wire[(WORD_SIZE-1):0] wr_addr, wr_data, rd_addr[0:(RD_CHANNELS-1)], 
    
    input wire mem_rd_done[0:(RD_CHANNELS-1)],
    input wire[(WORD_SIZE-1):0] mem_rd_data[0:(RD_CHANNELS-1)],
    
    output reg mem_rd_en[0:(RD_CHANNELS-1)],
    output reg[1:0] mem_wr_en, 
    output reg[$clog2(MEM_DEPTH-1)-1:0] mem_wr_addr, mem_rd_addr[0:(RD_CHANNELS-1)],
    output reg[(WORD_SIZE-1):0] mem_wr_data, 
    
    output reg invalid_wr_addr, invalid_rd_addr[0:(RD_CHANNELS-1)],
    output reg rd_done[0:(RD_CHANNELS-1)],
    output reg[(WORD_SIZE-1):0] rd_data[0:(RD_CHANNELS-1)]
);

    localparam ADDR_H = $clog2(MEM_DEPTH-1);
    localparam H_WORD = WORD_SIZE/2;

    initial begin
        mem_wr_en <= 0;
        invalid_wr_addr <= 0;
        mem_wr_addr <= 0;
        mem_wr_data <= 0;
        
        for (int i = 0; i < RD_CHANNELS; i++) begin
            invalid_rd_addr[i] <= 0;
            mem_rd_addr[i] <= 0;
            rd_data[i] <= 0;
            mem_rd_en[i] <= 0;
            rd_done[i] <= 0;
        end
    end

    always @ (posedge clk) begin
        if (reset) begin
            mem_wr_en <= 0;
            invalid_wr_addr <= 0;
            mem_wr_addr <= 0;
            mem_wr_data <= 0;
        end
        else begin
            mem_wr_addr <= wr_addr[(WORD_SIZE-1):1];
            
            if (wr_size) 
                mem_wr_data <= wr_data;
            else
                mem_wr_data <= {wr_data[(H_WORD-1):0], wr_data[(H_WORD-1):0]};
                
            if (wr_en) begin        
                if (wr_size & wr_addr[0]) begin
                    mem_wr_en <= 0;
                    invalid_wr_addr <= 1;
                end
                else
                    mem_wr_en[0] <= !wr_addr[0];
                    mem_wr_en[1] <= wr_size | wr_addr[0];
            end
            else
                mem_wr_en <= 0;
        end
    end
    
    generate
    genvar i;
        for (i = 0; i < RD_CHANNELS; i = i + 1) begin
            always @ (posedge clk) begin
                if (reset) begin
                    invalid_rd_addr[i] <= 0;
                    mem_rd_addr[i] <= 0;
                    rd_data[i] <= 0;
                    mem_rd_en[i] <= 0;
                    rd_done[i] <= 0;
                end
                else begin
                    rd_done[i] <= mem_rd_done[i];
                    mem_rd_en[i] <= rd_en[i];
                
                    if (rd_en[i]) begin
                        mem_rd_addr[i] <= rd_addr[i][(WORD_SIZE-1):1];
                        invalid_rd_addr[i] <= rd_size[i] & rd_addr[i][0];
                    end
                    
                    if (mem_rd_done[i]) begin
                        if (rd_size[i])
                            rd_data[i] <= mem_rd_data[i];
                        else begin
                            if (rd_addr[i][0])
                                rd_data[i] <= {
                                        mem_rd_data[i][(WORD_SIZE-1):H_WORD], 
                                        mem_rd_data[i][(WORD_SIZE-1):H_WORD]
                                    };
                            else
                                rd_data[i] <= {mem_rd_data[i][(H_WORD-1):0], mem_rd_data[i][(H_WORD-1):0]};
                        end
                    end
                end
            end
        end
    endgenerate 

endmodule
