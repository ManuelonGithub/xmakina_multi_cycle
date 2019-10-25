/**
 *  @File
 *      X-Makina Arrithmetic and Logic Unit.
 *  @brief
 *      Contains the code for the X-Makina Arrithmetic and Logic Unit.
 *  @author
 *      Manuel Burnay
 *  @date
 *      2019.10.25 (created)
 *  @date
 *      2019.10.25 (Last Modified)
 */

/**
 *	@brief
 *		X-Makina Arrithmetic and Logic Unit.
 *	@param
 *		WORD: Specifies the size of the ALU word in bits.
 *	@details
 *		Although the ALU word size is parameterized,
 *		The ALU is pretty specific to X-Makina.
 *		The ALU has been designed with speed in mind,
 *		Which means that a lot of elements in the ALU may be duplicated so
 *		The critical path for certain operations can be shortened.
 *		The ALU is, of course, Asynchronous. Any registering of the inputs/outputs
 *		are done outside of the module.
 */
module ALU
#(
    parameter WORD = 16
 )
(
    input wire[3:0] operation,
    
    input wire[3:0] status_old,	// C Z N V
    input wire[WORD-1:0] opA, opB,
    
    output reg[3:0] status_new,		// C Z N V
    output reg[WORD-1:0] out
);

	localparam HALF_WORD = WORD/2;

	enum {C, Z, N, V} STATUS_BITS;
	enum {
        ADD, ADDC, 
        SUB, SUBC,
		XOR, AND, 
		BIC, BIS,
		PASS_B, PASS_A,
        SWPB, SXT
    } ALU_FUNCTIONS;

	wire Cin = status_old[C];
	reg Csign, Cout;

	/*
	 * 	Overflow detection on arrithmetic operations:
	 *	The "XORing of the carry bits" method is implemented,
	 *	Where the Carry out of the Most significant bit addtion is XORed 
	 *	with the Carry out of the addtion operation in order to get the Overflow bit result.
	 */

	always @ (*) begin
		status_new <= status_old; 	// Sets up the new status with the values of the old status

		// NOR reduction of the operation result. 
		// Will only be 1 when all bits of out are 0.
		status_new[Z] <= ~|(out);
		status_new[N] <= out[WORD-1];

		Csign <= 0;
		Cout <= 0;

		case (operation)
			/*
			 *	ADD operation with overflow detection:
			 *	out = opA + opB
			 */
			ADD: begin
				{Csign, out[WORD-2:0]} <= opA[WORD-2:0] + opB[WORD-2:0];
		        {Cout,  out[WORD-1]}   <= opA[WORD-1] + opB[WORD-1] + Csign;
	        	
	        	status_new[C] <= Cout;
		        status_new[V] <= Csign ^ Cout;
			end

			/*
			 *	ADD with carry operation with overflow detection:
			 *	out = opA + opB + Cin
			 */
			ADDC: begin
				{Csign, out[WORD-2:0]} <= opA[WORD-2:0] + opB[WORD-2:0] + Cin;
		        {Cout,  out[WORD-1]}   <= opA[WORD-1] + opB[WORD-1] + Csign;
	        	
	        	status_new[C] <= Cout;
		        status_new[V] <= Csign ^ Cout;
			end

			/*
			 *	SUB operation with overflow detection:
			 *	out = opA + (-opB)
			 */
			SUB: begin
				{Csign, out[WORD-2:0]} <= opA[WORD-2:0] - opB[WORD-2:0];
		        {Cout,  out[WORD-1]}   <= opA[WORD-1] - opB[WORD-1] - Csign;
	        	
	        	status_new[C] <= Cout;
		        status_new[V] <= Csign ^ Cout;
			end

			/*
			 *	SUB with carry operation with overflow detection:
			 *	out = opA + (-opB) + (-Cin)
			 */
			SUBC: begin
				{Csign, out[WORD-2:0]} <= opA[WORD-2:0] - (opB[WORD-2:0]) - Cin;
		        {Cout,  out[WORD-1]}   <= opA[WORD-1] - opB[WORD-1] - Csign;
	        	
	        	status_new[C] <= Cout;
		        status_new[V] <= Csign ^ Cout;
			end

			/*
			 * Bitwise XOR operation
			 * out = opA ^ opB
			 */
			XOR: begin
				out <= opA ^ opB;
			end

			/*
			 * Bitwise XOR operation
			 * out = opA & opB
			 */
			AND: begin
				out <= opA & opB;
			end

			/*
			 * Bitwise Clear operation
			 * out = opA & ~opB
			 */
			BIC: begin
				out <= opA & ~opB;
			end

			/*
			 * Bitwise set operation / Bitwise OR operation
			 * out = opA | opB
			 */
			BIS: begin
				out <= opA | opB;
			end

			/*
			 * Pass B operation.
			 */
	        PASS_B: begin
	        	out <= opB;
			end

			/*
			 * Pass A operation.
			 */
	        PASS_A: begin
	        	out <= opA;
			end

			/*
			 * Swap half words of operand A.
			 */
	        SWPB: begin
	        	out <= {opA[HALF_WORD-1:0], opA[WORD-1:HALF_WORD]};
			end

			/*
			 * Sign extend the half word of operand A.
			 */
	        SXT: begin
	        	out <= {{HALF_WORD{opA[HALF_WORD-1]}}, opA[HALF_WORD-1:0]};
			end

			/*
			 * "Dummy" default operation.
			 */
			default: begin
				out <= opA;
			end
		endcase // operation
	end

endmodule : ALU