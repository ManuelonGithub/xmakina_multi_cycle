`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/18/2019 08:34:44 PM
// Design Name: 
// Module Name: xmakina_cpu_tb
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

import debug::*;

module xmakina_cpu_tb();

    reg clk, reset;
    
    reg mem_rd_done[0:1];
    reg[15:0] mem_rd_data[0:1];
    
    reg mem_rd_en[0:1];
    reg[1:0] mem_wr_en;
    reg[14:0] mem_wr_addr, mem_rd_addr[0:1];
    reg[15:0] mem_wr_data;

    debug_signals_t cpu_debug;

    xmakina_cpu_m #(.DEBUG(1)) cpu (
        .clk(clk), 
        .reset(reset),
        .rd_done(mem_rd_done),
        .rd_data(mem_rd_data),
        .rd_en(mem_rd_en),
        .wr_en(mem_wr_en), 
        .wr_addr(mem_wr_addr), 
        .rd_addr(mem_rd_addr),
        .wr_data(mem_wr_data),
        .debug_out(cpu_debug)
    );
    
    memory_m #(
        .MEM_FILE("test_mem_0.mem"),
        .USE_MEM_FILE(1)
    ) mem (
        .clk(clk),
        .rd_en(mem_rd_en),
        .wr_en(mem_wr_en),
        .wr_data(mem_wr_data),
        .wr_addr(mem_wr_addr), 
        .rd_addr(mem_rd_addr),
        .rd_done(mem_rd_done),
        .rd_data(mem_rd_data)
    );
    
    initial begin
        clk <= 0;
        reset <= 0;
    end
    
    always begin : CLOCK
        #5 clk <= ~clk;
    end

endmodule
