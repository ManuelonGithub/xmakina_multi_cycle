



/*
 * Logic unit
 * Contains the logic to perform n-bit bitwise logic operations.
 * The execution different operations are determined by the 
 * 2-bit "op" signal. 
 * here are the currently supported operations, in order:
 * XOR (00), AND (01), Bitwise Clear (10), OR/Bitwise Set (11)
 */
module logic_unit
#(
	parameter WORD = 16
 )
(
	input wire[1:0] op,
	input wire[WORD-1:0] a, b,
	output reg[WORD-1:0] res
);

// Ordering of the operation selection done by the op signal
enum {XOR, AND, BIC, BIS} LOGIC_OPERATIONS;

// Operation selection procedure
always @ (*) begin
    case (op)
    	XOR:	res <= a ^ b;	
    	AND:	res <= a & b;
    	BIC:	res <= a & ~b;
    	BIS:	res <= a | b;
    endcase
end
endmodule