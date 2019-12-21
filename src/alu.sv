/**
 * @File 	X-Makina Arrithmetic and Logic Unit.
 * @brief 	Contains the code for the X-Makina Arrithmetic and Logic Unit.
 * @author 	Manuel Burnay
 * @date 	2019.10.25 (created)
 * @date 	2019.10.25 (Last Modified)
 */

/*
 * ALU module.
 * Combines all computing units and selects which result is outputted,
 * as well as handling result flags logic.
 * op signal determines which compute block and operation is used.
 * op[3:2] determines the compute block enabled:
 * arrithmetic (00), logic (01), shifter (10), stray (11).
 * These blocks are also correlated with which flags will be written 
 * to the status register.
 * op[1:0] are then passed to each block to select with internal operation
 * will be selected.
 */
module ALU
#(
    parameter WORD = 16
 )
(
	input wire 				cin,
    input wire[3:0] 		op,
    input wire[WORD-1:0] 	a, b,
    output reg[3:0] 		flags,		// C Z N V
    output reg[WORD-1:0]	res
);

// Ordering of the compute blocks according to their selection
// via op[3:2]
enum {ARRITHMETIC, LOGIC, SHIFTER, STRAY} ALU_BLOCKS;

// Ordering of the flags bits 
enum {C, Z, N, V} FLAG_BITS;

// Array of the results coming out of the compute blocks
wire[WORD-1:0] bres[0:3];

// Carry out and overflow signals out of the arrithmetic and shifter blocks
wire arr_cout, arr_ovf, shift_cout;

// Arrithmetic unit component instantiation
arrithmetic_unit #(.WORD(WORD)) AU (
	.cin (cin),
	.op  (op[1:0]),
	.a   (a),
	.b   (b),
	.res (bres[ARRITHMETIC]),
	.cout(arr_cout),
	.ovf (arr_ovf)
);

// Logic unit component instantiation
logic_unit #(.WORD(WORD)) LU (
	.op (op[1:0]),
	.a  (a),
	.b  (b),
	.res(bres[LOGIC])
);

// Shifter unit component instantiation
shifter_unit #(.WORD(WORD)) SU (
	.cin (cin),
	.op  (op[0]),
	.src (a),
	.res (bres[SHIFTER]),
	.cout(shift_cout)
);

// Stary operations unit component instantiation
stray_op_unit #(.WORD(WORD)) STU (
	.op (op[1:0]),
	.a  (a),
	.b  (b),
	.res(bres[STRAY])
);

always @ (*) begin
	res <= bres[op[3:2]];	// Block result selection

	flags[Z] <= ~|res;			// Zero-flag logic
	flags[N] <= res[WORD-1];	// Sign flag logic

	if (op[3:2] == ARRITHMETIC)	// signed Arrithmetic overflow flag logic
		flags[V] <= arr_ovf;
	else
		flags[V] <= 0;

	case (op[3:2])				// Carry flag logic
		ARRITHMETIC:	flags[C] <= arr_cout;
		SHIFTER:		flags[C] <= shift_cout;
		default:		flags[C] <= 0;
    endcase
end

endmodule : ALU