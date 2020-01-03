/*
 * file: hidden_registers.sv
 * author: Manuel Burnay
 * date created: 2019.12.17
 */

/*
 * Hidden registers module.
 * Register File that contains all hidden registers that the 
 * processor's datapath requires.
 * It is different from a regular register file due to each
 * register having separate sources signal lanes and write enable signals.
 */
module hidden_registers 
#(
	parameter WORD = 16
 )
(
	input wire clk_i, arst_i,

	input wire MARwr_i, IMDRwr_i, OMDRwr_i, IRwr_i,
	input wire[WORD-1:0] MARdat_i, IMDRdat_i, OMDRdat_i, IRdat_i,

	output reg[WORD-1:0] MARdat_o, IMDRdat_o, OMDRdat_o, IRdat_o
);

int i;

always @ (posedge clk_i, posedge arst_i) begin
    if (arst_i) begin
        MARdat_o <= 0;
        IMDRdat_o <= 0;
        OMDRdat_o <= 0;
        IRdat_o <= 0;
    end
    else begin
        if (MARwr_i)	MARdat_o <= MARdat_i;
        if (IMDRwr_i)	IMDRdat_o <= IMDRdat_i;
        if (OMDRwr_i)	OMDRdat_o <= OMDRdat_i;
        if (IRwr_i)		IRdat_o <= IRdat_i;
	end
end

endmodule