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
#(parameter DEBUG = 0)
(
    input wire clk,
    input wire status_wr,
    input wire[1:0] wr_en,
    input wire [15:0] wr_data,
    input wire [3:0] status_in, status_wr_mode,
    output reg [15:0] PSW_out
);
    
    enum {C, Z, N, V} STATUS_bits;

    reg [15:0] PSW_reg = 0;

    typedef struct packed {
        logic C, Z, N, V;
    } status_t;

    typedef struct packed {
        status_t status, wr_mode;
    } psw_debug_t;

    psw_debug_t debug;

    always @ (*) begin : DEBUG_CONSTRUCTS
        debug.status.C <= PSW_reg[C];
        debug.status.Z <= PSW_reg[Z];
        debug.status.N <= PSW_reg[N];
        debug.status.V <= PSW_reg[V];

        debug.wr_mode.C <= status_wr_mode[C];
        debug.wr_mode.Z <= status_wr_mode[Z];
        debug.wr_mode.N <= status_wr_mode[N];
        debug.wr_mode.V <= status_wr_mode[V];
    end
    
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

    always @ (*) begin
        PSW_out <= PSW_reg;
    end

endmodule
