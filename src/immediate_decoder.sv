



module immediate_decoder
#(
	parameter WORD = 16
 )
(
	input wire[WORD-1:0] instWord_i,
	output reg[WORD-1:0] immVal_o
);

/* 
 * Bits 12:11 can be used to differentiate between the four
 * different possible immediate values in the instruction word
 */

enum {MOVL, MOVLZ, MOVLS, MOVH} IMMEDIATE_TYPES;

wire[1:0] immType = instWord_i[12:11];

localparam IMM_H = 10;
localparam IMM_L = 3;

always @ (*) begin
 	case (immType)
        MOVL, MOVLZ:	immVal_o <= {8'h00, instWord_i[IMM_H:IMM_L]};
        MOVLS:			immVal_o <= {8'hFF, instWord_i[IMM_H:IMM_L]};
        MOVH:			immVal_o <= {instWord_i[IMM_H:IMM_L], 8'h00};
    endcase // inst[12:11]
end

endmodule