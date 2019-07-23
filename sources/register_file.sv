`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/31/2019 11:33:47 PM
// Design Name: 
// Module Name: register_file
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


module register_file
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

    output reg[1:0] PC_wr_en,
    output reg[REG_WIDTH-1:0] rd_data[0:1], PC_out
);

    localparam HALF_WORD = REG_WIDTH/2;
    
    localparam PC_ADDR = 7;
    
    reg[HALF_WORD-1:0] register_l[0:REG_COUNT-1], register_h[0:REG_COUNT-1];
    
    // reg PC_wr = (wr_addr == PC_ADDR);
    wire PC_rd[0:1] = {(rd_addr[0] == PC_ADDR), (rd_addr[1] == PC_ADDR)};
    reg[REG_WIDTH-1:0] reg_file_out[0:1]; 
    
    assign PC_wr_en = {{2{(wr_addr == PC_ADDR)}} & wr_en};
    assign PC_out = wr_data;

    typedef enum logic[2:0] {
        R0,
        R1,
        R2,
        R3,
        R4,
        R5,
        R6,
        R7
    } OPERANDS;

    typedef enum logic[1:0] {
        NO_WRITE,
        LOW_BYTE,
        HIGH_BYTE,
        WORD
    } REG_WRITE_MODE;

    typedef struct packed {
        logic[15:0] R0, R1, R2, R3, R4, R5, R6, R7;
    } reg_file_t;

    typedef struct packed {
        OPERANDS dst, src_a, src_b;
        logic[15:0] R0, R1, R2, R3, R4, R5, R6, R7;
        REG_WRITE_MODE wr_mode;
    } reg_file_debug_t;

    reg_file_debug_t debug;

    always @ (*) begin : DEBUG_CONSTRUCTS
        if (DEBUG) begin
            debug.src_a <= OPERANDS'(rd_addr[0]);
            debug.src_b <= OPERANDS'(rd_addr[1]);
            debug.dst <= OPERANDS'(wr_addr);

            debug.R0 <= {register_h[0], register_l[0]};
            debug.R1 <= {register_h[1], register_l[1]};
            debug.R2 <= {register_h[2], register_l[2]};
            debug.R3 <= {register_h[3], register_l[3]};
            debug.R4 <= {register_h[4], register_l[4]};
            debug.R5 <= {register_h[5], register_l[5]};
            debug.R6 <= {register_h[6], register_l[6]};
            debug.R7 <= PC_in;

            debug.wr_mode <= REG_WRITE_MODE'(wr_en);
        end
        else
            debug <= 0;
    end

    initial begin
        for (int i = 0; i < REG_COUNT; i++) begin
            register_l[i] <= 0;
            register_h[i] <= 0;
        end
    end
    
    always @ (posedge clk) 
    begin
        if (wr_en[0])
            register_l[wr_addr] <= wr_data[HALF_WORD-1:0];
        if (wr_en[1])
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
