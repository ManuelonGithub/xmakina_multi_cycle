`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/18/2019 05:36:44 PM
// Design Name: 
// Module Name: memory_tb
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


module memory_tb();

    reg clk, reset, wr_en, wr_size, rd_en[0:1], rd_size[0:1]; 
    reg[15:0] wr_addr, wr_data, rd_addr[0:1]; 
    
    reg mem_rd_done[0:1];
    reg[15:0] mem_rd_data[0:1];
    
    reg mem_rd_en[0:1];
    reg[1:0] mem_wr_en;
    reg[14:0] mem_wr_addr, mem_rd_addr[0:1];
    reg[15:0] mem_wr_data;
    
    reg invalid_wr_addr, invalid_rd_addr[0:1];
    reg rd_done[0:1];
    reg[15:0] rd_data[0:1];
    
    reg fetch_en;
    reg[15:0] PC_in;
    
    reg fetch_err, fetch_done;
    reg[15:0] PC_current, fetch_data, PC_out;
    
    cpu_memory_controller mem_controller(.*);
    
    instruction_fetch_unit fetch(
        .en(fetch_en),
        .PC_in(PC_in),
        .mem_err(invalid_rd_addr[0]),
        .mem_done(rd_done[0]),
        .mem_data(rd_data[0]),
        .mem_en(rd_en[0]),
        .mem_access_size(rd_size[0]),
        .mem_addr(rd_addr[0]), 
        .fetch_err(fetch_err),
        .fetch_done(fetch_done),
        .fetch_data(fetch_data), 
        .PC_out(PC_out)
    );
    
    memory_m mem (
        .clk(clk),
        .rd_en(mem_rd_en),
        .wr_en(mem_wr_en),
        .wr_data(mem_wr_data),
        .wr_addr(mem_wr_addr), 
        .rd_addr(mem_rd_addr),
        .rd_done(mem_rd_done),
        .rd_data(mem_rd_data)
    );
    
    reg [15:0] f_i = 0;
    int wr_i = 0;
    
    initial begin 
        clk = 0;
        reset = 0;
        wr_en = 0;
        wr_size = 0;
        rd_en[1] = 0;
        rd_size[1] = 0;
        
        wr_addr = 0;
        wr_data = 0;
        rd_addr[1] = 0;
        
        fetch_en = 0;
        PC_in = 0;
    end
    
    always begin : CLOCK
        #5 clk <= ~clk;
    end
    
//    always @ (posedge clk) begin : READ_WRITE_TEST
//        wr_addr = wr_i;
//        wr_data = 'hFF - wr_i;
//        rd_addr[0] = wr_i - 1;
        
//        wr_i = wr_i + 1;
        
//        rd_en = {1,1};
//        rd_size = {1,1};
//        wr_en = 1;
//        wr_size = 0;
//    end

    always @ (negedge clk) begin : FETCH_TEST
        fetch_en <= ~fetch_en;
//        rd_en[1] <= ~rd_en[1];
        
        rd_size[1] <= 1;
    end
    
    always @ (posedge clk) begin
        if (fetch_en)
            PC_in <= PC_out;
    end

endmodule
