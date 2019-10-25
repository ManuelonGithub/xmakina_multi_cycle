/**
 * @File    X-Makina Shifter Module file.
 * @brief   Contains the code for the X-Makina Shifter.
 * @author  Manuel Burnay
 * @date    2019.10.25 (created)
 * @date    2019.10.25 (Last Modified)
 */

/**
 * @brief   Barrel Shifter that can perform 
            Shift Arrithmetic and Rotate right with Carry.
 * @input   operation: Operation for the Shifter to compute.
 *                     This Shifter currently only supports 2 operations.
 *                     They can be seen in the SHIFT_OPERATIONS 
 *                     enumeration in the module.
 * @input   status_old: Old status bits of the machine.
 *                      They are used to obtain the carry in bit, and to
 *                      passthrough if a Shift operation does not effect that
 *                      specific bit.
 * @input   in: Shifter input.
 * @input   shift: Shift count value. 
 * @output  status_new: New status bits resolved by the Shifter based
 *                      on the operation it performed and the old status.
 * @output  out: Output result of the Shifter.
 * @param   WORD: Specifies the size of the Shifter word in bits.
 * @details This shifter module uses a 
 *          single barrel shifter to perform its operations.
 *          It uses the ">>" verilog operator, so performance of the shifter is 
 *          Synthesizer dependent.
 *          This module is meant to be set up so it can chain with other shifters 
 *          for better pipeline performance and/or 
 *          enable operations on fractions of the Word size.
 *          To accomplish the latter, "pass" operation is implemented
 *          so the shifter does not operate on the result and status.
 */
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

            // Passthrough operation
            default: begin
            	barrel_shift_in <= {{WORD{in[WORD-1]}},in};;
            	out <= in;
            end
        endcase
    end

endmodule : shifter