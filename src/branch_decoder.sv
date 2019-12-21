



module branch_decoder
#(
	parameter WORD = 16
 )
(
	input wire[WORD-1:0] instWord_i,
	output reg[WORD-1:0] branchOffs_o
);

/*
 * A branch instruction's last bits (15:13) are
 * 000 for a branch with link
 * 001 for a Conditional brancH
 * 
 * Since this module only deals with branch instructions,
 * we only need to account for the differences between the branching instructions.
 * In this case it's bit 13. 
 * if 0 then let's assume its a conditional branch,
 * if 1 then let's assume it's a branch with link.
 */

localparam COND_H 	= 9;
localparam BL_H 	= 12;

localparam COND_SXT = WORD - 1 - COND_H;
localparam BL_SXT  	= WORD - 1 - BL_H;

enum {BRANCH_W_LINK, CONDITIONAL_BRANCH} BRANCH_TYPES;

wire branchType = instWord_i[13];

 always @ (*) begin
 	if (branchType)	// 1 = Conditional branch
 		branchOffs_o <= {{COND_SXT{instWord_i[COND_H]}}, instWord_i[COND_H:0]};
 	else
 		branchOffs_o <= {{BL_SXT{instWord_i[BL_H]}}, instWord_i[BL_H:0]};
 end

endmodule