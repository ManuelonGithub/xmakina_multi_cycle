



module PC_offset_select
#(
	parameter WORD = 16,
	parameter DEF_OFFS = 16'h2
 )
(
	input wire sel_i,
	input wire[WORD-1:0] branch_i, pc_i,
	output reg[WORD-1:0] pc_o
);

reg[WORD-1:0] offset;

always @ (*) begin
	if (sel_i)	offset <= branch_i;
	else		offset <= DEF_OFFS;

	pc_o <= pc_i + offset;
end

endmodule