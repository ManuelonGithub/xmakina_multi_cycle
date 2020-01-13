



module button_press_detector
#(
	parameter BUTTONS = 1
 )
(
	input wire clk_i,
	input wire[BUTTONS-1:0] button_i,

	output reg[BUTTONS-1:0] press_o
);

reg[BUTTONS-1:0] buttonLatch;

always @ (*) begin
	press_o <= ~buttonLatch & button_i;
end

always @ (posedge clk_i) begin
	buttonLatch <= button_i;
end

endmodule : button_press_detector