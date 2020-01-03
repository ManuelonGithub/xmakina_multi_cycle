



module memory_offset_select
#(
	parameter WORD = 16
 )
(
	input wire[2:0] sel_i,
	input wire[WORD-1:0] offset_i,

	output reg[WORD-1:0] offset_o 
);

enum {PLUS_2, PLUS_1, MINUS_2, MINUS_1, OFFS, ZERO} OFFSET_SELECTIONS;

always @ (*) begin
	case (sel_i)
		PLUS_2:		offset_o <= 2;
		PLUS_1:		offset_o <= 1;
		MINUS_2:	offset_o <= -16'h2;
		MINUS_1:	offset_o <= -16'h1;
		OFFS:		offset_o <= offset_i;
		default:	offset_o <= 0;
	endcase
end

endmodule