`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/01/2019 02:40:58 PM
// Design Name: 
// Module Name: program_status_register_m
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


module program_status_register_m
(
    input wire [15:0] wr_data,
    input wire [3:0] status_in,
    input wire [1:0] wr_en,
    input wire clk, status_wr, 
    output reg [15:0] PSW_out, 
    output reg [7:0] branch_logic
);
    
    enum {C, Z, N, SLP, V} STATUS_bits;
    enum {BEQ, BNE, BHS, BLO, BN, BGE, BLT, BAL} BRANCH_TYPES;
    
    reg [7:0] PSW_l, PSW_h;
    
    always @ (posedge clk) 
    begin
        if (wr_en[0])
            PSW_l <= wr_data[7:0];
        else if (status_wr) begin
            PSW_l[2:0] <= status_in[2:0];
            PSW_l[V] <= status_in[3];
        end
        
        if (wr_en[1])
            PSW_h <= wr_data[15:8];
    end
    
    always @ (*) 
    begin
        PSW_out <= {PSW_h, PSW_l};
       
        branch_logic[BEQ] <= PSW_l[Z];
        branch_logic[BNE] <= !PSW_l[Z];
        branch_logic[BHS] <= PSW_l[C];
        branch_logic[BLO] <= !PSW_l[C];
        branch_logic[BN]  <= PSW_l[N];
        branch_logic[BGE] <= !(PSW_l[N] ^ PSW_l[V]);
        branch_logic[BLT] <= (PSW_l[N] ^ PSW_l[V]);
        branch_logic[BAL] <= 1;

    end

endmodule
