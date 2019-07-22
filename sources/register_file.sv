`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/31/2019 11:33:47 PM
// Design Name: 
// Module Name: register_file_m
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


module register_file_m
#(
    parameter DEBUG = 0,
    parameter REG_WIDTH = 16,
    parameter REG_COUNT = 8
 )
(
    input wire clk, rd_size,
    input wire[1:0] wr_en,
    input wire[$clog2(REG_COUNT-1)-1:0] wr_addr, rd_addr[0:1],
    input wire[REG_WIDTH-1:0] wr_data, PC_in,

    output reg[REG_WIDTH-1:0] file_out[0:REG_COUNT-1],

    output reg[1:0] PC_wr_en,
    output reg[REG_WIDTH-1:0] rd_data[0:1], PC_out
);

    localparam HALF_WORD = REG_WIDTH/2;
    enum {WORD, BYTE} ACCESS_TYPES;
    
    localparam PC_ADDR = 7;
    
    reg[HALF_WORD-1:0] register_l[0:REG_COUNT-1], register_h[0:REG_COUNT-1];
    
    // reg PC_wr = (wr_addr == PC_ADDR);
    wire PC_rd[0:1] = {(rd_addr[0] == PC_ADDR), (rd_addr[1] == PC_ADDR)};
    reg[REG_WIDTH-1:0] reg_file_out[0:1]; 
    
    assign PC_wr_en = {{2{(wr_addr == PC_ADDR)}} & wr_en};
    assign PC_out = wr_data;

    generate
        if (DEBUG) begin
            always @ (*) begin
                for (int i = 0; i < REG_COUNT-1; i++) begin
                    file_out[i] <= {register_h[i], register_l[i]};
                end

                file_out[PC_ADDR] <= PC_in;
            end
        end
        else
            always @ (*) begin
                for (int i = 0; i < REG_COUNT; i++) begin
                    file_out[i] <= 0;
                end
            end
    endgenerate

    initial begin
        for (int i = 0; i < REG_COUNT; i++) begin
            register_l[i] <= 0;
            register_h[i] <= 0;
        end
    end
    
    always @ (posedge clk) 
    begin
        if (wr_en[BYTE])
            register_l[wr_addr] <= wr_data[HALF_WORD-1:0];
        if (wr_en[WORD])
            register_h[wr_addr] <= wr_data[REG_WIDTH-1:HALF_WORD];
    end
    
    generate
    genvar rd_i;
        for (rd_i = 0; rd_i < 2; rd_i = rd_i +1) begin
            always @ (*) begin
                if (PC_rd[rd_i])
                    reg_file_out[rd_i] <= PC_in;
                else
                    reg_file_out[rd_i] <= {register_h[rd_addr[rd_i]], register_l[rd_addr[rd_i]]};
                    
                
                rd_data[rd_i][HALF_WORD-1:0] <= reg_file_out[rd_i][HALF_WORD-1:0];
                
                if (rd_size)
                    rd_data[rd_i][REG_WIDTH-1:HALF_WORD] <= reg_file_out[rd_i][REG_WIDTH-1:HALF_WORD];
                else
                    rd_data[rd_i][REG_WIDTH-1:HALF_WORD] <= {HALF_WORD{reg_file_out[rd_i][HALF_WORD-1]}};
            end
        end
    endgenerate
    
endmodule
