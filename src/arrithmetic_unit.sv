


/*
 * Arrithmetic unit
 * Contains the logic to perform n-bit addition or 
 * subtraction with overflow detection.
 * With or without carry.
 * The execution different operations are determined by the 
 * "op" signal. 
 * op[1] is used to determine whether its an addition or subtraction.
 * op[0] is used to determine whether to add the carry in or not.
 */
module arrithmetic_unit
#(
	parameter WORD = 16
 )
(
	input wire cin,
	input wire[1:0] op,
	input wire[WORD-1:0] a, b,
	output reg[WORD-1:0] res,
	output reg cout, ovf
);

// Op[1] = Add (0) or Subtract (1)
// Op[0] = without carry (0) or with carry (1)

wire[WORD-1:0] opA = a;
wire[WORD-1:0] opB = b ^ {WORD{op[1]}};
wire opCin = (cin & op[0]) ^ op[1];
reg csign;

// Simple addtion (XOR) of the operands' most-significand bits
wire MSB_sum = opA[WORD-1] ^ opB[WORD-1];

// dummy signal so that addition can be done with a singla addition unit.
reg dummy;

always @ (*) begin
    // Addition that captures internal carry on the MSG bit
	{csign, res[WORD-2:0], dummy} <= {opA[WORD-2:0], opCin} + {opB[WORD-2:0], opCin};
	
	// Simple addition (Full-adder style) for the final bit & carry out
    res[WORD-1] <= MSB_sum ^ csign;
    cout        <= (MSB_sum & csign) | (opA[WORD-2:0] & opB[WORD-2:0]);
    
    // Overflow detection using the carry from the sign bit and carry out
    ovf <= csign ^ cout;
end
endmodule