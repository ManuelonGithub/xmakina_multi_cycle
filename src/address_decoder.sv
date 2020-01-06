/*
 * file: address_decoder.sv
 * author: Manuel Burnay
 * date created: 2019.12.18
 */

/*
 * Address Decoder unit.
 * Performs checks on the memory address for misalignment 
 * and for any special values required by the X-Makina ISA specification.
 * Also generates the Byte lane select signal that the memory controller takes in.
 */
module address_decoder 
#(
	parameter WORD = 16,
	parameter EXC_RET = 16'hFFFF,
	parameter PSW_ADDR = 16'hFFFC
 )
(
	input wire byteEn_i,
	input wire[WORD-1:0] addr_i,
	output reg badMem_o, pswAddr_o,
	output reg[1:0] datSel_o
);

enum {ACC_BAD, ACC_LB, ACC_HB, ACC_WORD} ACCESS_PARAMETERS;

always @ (*) begin
	badMem_o <= ~byteEn_i & addr_i[0];

	// PSW access check
	pswAddr_o <= (addr_i == PSW_ADDR);

	// Address "Byte Lane" Decoding
	case ({byteEn_i, addr_i[0]})
		2'b00:	datSel_o 	<= ACC_WORD;	// Both lanes enabled
		2'b01:	datSel_o 	<= ACC_BAD; 	// Both lanes disabled
		2'b10:	datSel_o 	<= ACC_LB;		// Low-byte lane enabled
		2'b11:	datSel_o	<= ACC_HB;		// High-byte lane enabled
	endcase
end

endmodule