



module address_accumulator
#(
	parameter WORD = 16
 )
(
	input wire[1:0] 		op,
	input wire[WORD-1:0] 	src,
	output reg[WORD-1:0]	res
);

enum {PLUS_2, PLUS_1, MINUS_2, MINUS_1} ADDR_ACC_OPS;

reg[WORD-1:0] addr_acc;

always @ (*) begin
	case (op)
		PLUS_2:		addr_acc <= 16'h2;
		PLUS_1:		addr_acc <= 16'h1;
		MINUS_2:	addr_acc <= -16'h2;
		MINUS_1:	addr_acc <= -16'h1;
	endcase
	
	res <= src + addr_acc;
end

endmodule