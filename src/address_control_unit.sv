


// cmd_o  signal:
// 	| r/w | byte sel |
// 	|  0  |  0    0  |	-> res
// 	|  0  |  0    1  |  -> rw_i = 0, size_i = 1, addr_i[0] = 0
// 	|  0  |  1    0  |  -> rw_i = 0, size_i = 1, addr_i[0] = 1
// 	|  0  |  1    1  |  -> rw_i = 0, size_i = 0, addr_i[0] = 0
// 	|  1  |  0    0  |	-> res
// 	|  1  |  0    1  |  -> rw_i = 1, size_i = 1, addr_i[0] = 0
// 	|  1  |  1    0  |  -> rw_i = 1, size_i = 1, addr_i[0] = 1
// 	|  1  |  1    1  |  -> rw_i = 1, size_i = 1, addr_i[0] = 0

/*
 * Address control unit.
 * Performs checks on the memory address for misalignment 
 * and for any special values required by the X-Makina ISA specification.
 * Also generates the data access command that the memory controller takes in.
 */
module address_control_unit 
#(
	parameter WORD = 16,
	parameter EXC_RET = 16'hFFFF
 )
(
	input wire byte_access, rw_i,
	input wire[WORD-1:0] addr_i,
	output reg bad_addr_o, exc_ret_o,
	output reg[2:0] cmd_o
);

// Ordering of the bits in the command signal and their meaning
// LB = Low Byte, HB = High Byte, RW = Read/Write selection
enum {LB, HB, RW} COMMAND_BITS;

always @ (*) begin
	// Misaligned memory address check
	bad_addr_o <= ~byte_access & addr_i[0];	// attempting to read word from odd address

	// Exception return value check
	exc_ret_o <= (addr_i == EXC_RET);


	// low-byte enabled whenever the lsb of address is 0
	cmd_o[LB] <= ~addr_i[0];

	// high-byte enabled if read the full word or if reading a byte from an odd memory address
	cmd_o[HB] <= byte_access ~^ addr_i[0];

	// Read/Write selection passthrough
	cmd_o[RW] <= rw_i;
end

endmodule