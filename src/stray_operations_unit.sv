/*
 * file: stray_operations_unit.sv
 * author: Manuel Burnay
 * date created: 2019.12.17
 */

/*
 * Stray operations unit
 * Contains the logic to perform n-bit miscellaneous operations
 * that are needed throughout the CPU's execution.
 * The execution different operations are determined by the 
 * 2-bit "op" signal. 
 * here are the currently supported operations, in order:
 * Pass a (00), pass b (01), Swap bytes in a (10), Sign extend lower byte in a (11)
 */
module stray_op_unit
#(
	parameter WORD = 16
 )
(
	input wire[1:0] op,
	input wire[WORD-1:0] a, b,
	output reg[WORD-1:0] res
);

localparam HALF_WORD = WORD/2;

// Ordering of the operations that are selected via the op signal
enum {PASS_B, SWPB, SXT, PASS_A} STRAY_OPERATIONS;

// operation selection procedure
always @ (*) begin
    case (op)
    	SXT:	res <= {{HALF_WORD{a[HALF_WORD-1]}}, a[HALF_WORD-1:0]};
    	SWPB:	res <= {a[HALF_WORD-1:0], a[WORD-1:HALF_WORD]};
    	PASS_A:	res <= a;
    	PASS_B:	res <= b;
    endcase
end
endmodule