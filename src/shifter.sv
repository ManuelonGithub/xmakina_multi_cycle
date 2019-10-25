

module shifter
#(
    parameter WORD = 16
 )
(
    input wire[1:0] operation,
    input wire[3:0] status_old,	// C Z N V
    input wire[$clog2(WORD)-1:0] shift,
    input wire[WORD-1:0] in,

    output reg[3:0] status_new,		// C Z N V
    output reg[WORD-1:0] out
);
	enum {C, Z, N, V} STATUS_BITS;
	enum {SHIFT_RIGHT_ARITHMETIC, ROTATE_RIGHT} SHIFT_OPERATIONS;
    
    wire Feedin = status_old[0];
    reg[WORD-1:0] barrel_shift_out;
    reg[(WORD*2)-1:0] barrel_shift_in;

    /*
     * 	Notes on shifting and rotating:
     * 		This module is set up so it can chain with other shifters 
     *		for better pipeline performance and/or 
     *		enable operations on fractions of the Word size.
     *		To accomplish the latter, "pass" operation is implemented
     *		so the shifter does not operate on the result and status.
     */
    always @ (*) 
    begin  
    	status_new <= status_old;
    	barrel_shift_out <= barrel_shift_in >> shift;

        case (operation)
            SHIFT_RIGHT_ARITHMETIC: begin
            	barrel_shift_in <= {{WORD{in[WORD-1]}},in};
            	out <= barrel_shift_out;
            	status_new[Z] <= ~|(out);
				status_new[N] <= out[WORD-1];
				status_new[C] <= barrel_shift_in[shift-1];
            end

            ROTATE_RIGHT: begin
            	barrel_shift_in <= {in[WORD-2:0], Feedin, in};
            	out <= barrel_shift_out;
            	status_new[Z] <= ~|(out);
				status_new[N] <= out[WORD-1];
				status_new[C] <= barrel_shift_in[shift-1];
            end
            default: begin
            	barrel_shift_in <= {{WORD{in[WORD-1]}},in};;
            	out <= in;
            end
        endcase
    end

endmodule