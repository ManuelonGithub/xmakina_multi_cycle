



module operand_decoder
#(
	parameter WORD = 16
 )
(
	input wire[WORD-1:0] instWord_i,
	output reg[WORD-1:0] branchOffs_o, immVal_o, memOffs_o
);

branch_decoder branch (
	.instWord_i  (instWord_i),
	.branchOffs_o(branchOffs_o)
);

immediate_decoder immediate (
	.instWord_i(instWord_i),
	.immVal_o  (immVal_o)
);

localparam MEM_H = 13;
localparam MEM_L = 7;
localparam MEM_SXT = WORD-1 - MEM_H;

assign memOffs_o = {{MEM_SXT{instWord_i[MEM_H]}}, instWord_i[MEM_H:MEM_L]};

endmodule