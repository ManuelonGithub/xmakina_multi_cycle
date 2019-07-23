`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/22/2019 03:03:55 PM
// Design Name: 
// Module Name: branch_condition_logic_block_m
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


module branch_logic_block
(
	input wire[3:0] status, 
	input wire[2:0] branch_cond,
	output reg result
);

	reg[8:0] branch_logic;

	enum {C, Z, N, V} STATUS_bits;
    enum {BEQ, BNE, BHS, BLO, BN, BGE, BLT, BAL} BRANCH_TYPES;



	always @ (*) begin
        case (branch_cond)
        	BEQ:
        		result <= status[Z];
        	BNE:
        		result <= !status[Z];
        	BHS:
        		result <= status[C];
        	BLO:
        		result <= !status[C];
        	BN:
        		result <= status[N];
        	BGE:
        		result <= ~(status[N] ^ status[V]);
        	BLT:
        		result <= (status[N] ^ status[V]);
        	BAL:
        		result <= 1;
		endcase
	end

endmodule
