



/*
 * Stray operations unit
 * Contains the logic to perform n-bit shift and roll operations
 * that the X-Makina CPU supports.
 * The execution different operations are determined by the 
 * 2-bit "op" signal. 
 * here are the currently supported operations, in order:
 * Shift right arrithmetically (00), Rotate right with Carry (01), Swap bytes in a (10), Sign extend lower byte in a (11)
 */
module shifter_unit
#(
	parameter WORD = 16
 )
(
    input wire cin, op,
	input wire[WORD-1:0] src,
	output reg[WORD-1:0] res,
    output reg cout
);

// Operation seletion ordering done by the op signal
enum {SRA, RRC} SHIFTER_BLOCK_FUNCTIONS;

// Operation selection procedure
always @ (*) begin
    case (op)
        SRA:    res <= {src[WORD-1], src[WORD-1:1]};
        RRC:    res <= {cin, src[WORD-1:1]};
    endcase
    
    cout <= src[0];
end
endmodule