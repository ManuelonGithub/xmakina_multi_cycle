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


module program_status_register
(
    input wire clk,
    input wire status_wr,
    input wire[1:0] wr_en,
    input wire [15:0] wr_data,
    input wire [3:0] status_in, status_wr_mode,
    output reg [15:0] PSW_out, 
    output reg [7:0] branch_logic
);
    
    enum {C, Z, N, V} STATUS_bits;
    enum {BEQ, BNE, BHS, BLO, BN, BGE, BLT, BAL} BRANCH_TYPES;
    
    reg [15:0] PSW_reg = 0;
    
    always @ (posedge clk)  begin
        if (status_wr) begin
            for (int i = 0; i < 4; i++) begin
                if (status_wr_mode[i]) 
                    PSW_reg[i] <= status_in[i];
            end
        end
        else begin
            if (wr_en[0])
                PSW_reg[7:0] <= wr_data[7:0];

            if (wr_en[1])
                PSW_reg[15:8] <= wr_data[15:8];
        end
    end
    
    always @ (*) 
    begin
        PSW_out <= PSW_reg;
       
        branch_logic[BEQ] <= PSW_reg[Z];
        branch_logic[BNE] <= !PSW_reg[Z];
        branch_logic[BHS] <= PSW_reg[C];
        branch_logic[BLO] <= !PSW_reg[C];
        branch_logic[BN]  <= PSW_reg[N];
        branch_logic[BGE] <= !(PSW_reg[N] ^ PSW_reg[V]);
        branch_logic[BLT] <= (PSW_reg[N] ^ PSW_reg[V]);
        branch_logic[BAL] <= 1;

    end

endmodule
