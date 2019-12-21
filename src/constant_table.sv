



/*
 * Constant table module.
 * Simple ROM module that contains the constant values
 * as established by the X-Makina ISA.
 */
module constant_table
#(
	parameter WORD = 16
 )
(
    input wire [2:0] addr,
    output wire [WORD-1:0] data
);
	
	// Constant table ROM
    reg [WORD-1:0] ConstantTable[7:0] = {-1, 48, 32, 8, 4, 2, 1, 0};
    
    assign data = ConstantTable[addr];
endmodule
