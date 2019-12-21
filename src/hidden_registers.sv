



module hidden_registers 
#(
	parameter WORD = 16
 )
(
	input wire clk_i, rst_i,

	input wire MARwr_i, IMDRwr_i, OMDRwr_i, IRwr_i,
	input wire[WORD-1:0] MARdat_i, IMDRdat_i, OMDRdat_i, IRdat_i,

	output reg[WORD-1:0] MARdat_o, IMDRdat_o, OMDRdat_o, IRdat_o
);

int i;

always @ (posedge clk_i, posedge rst_i) begin
	if (MARwr_i)	MARdat_o <= MARdat_i;
	if (IMDRwr_i)	IMDRdat_o <= IMDRdat_i;
	if (OMDRwr_i)	OMDRdat_o <= OMDRdat_i;
	if (IRwr_i)		IRdat_o <= IRdat_i;
end

endmodule