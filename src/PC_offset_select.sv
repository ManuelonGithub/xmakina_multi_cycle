/*
 * file: address_decoder.sv
 * author: Manuel Burnay
 * date created: 2019.12.19
 */

/*
 * PC Offset Select unit.
 * Performs the addition between the PC value 
 * and a selected offset (b/w a default offset & an external offset).
 */
module PC_offset_select
#(
	parameter WORD = 16,
	parameter DEF_OFFS = 16/8
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