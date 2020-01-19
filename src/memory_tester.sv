



module memory_tester
(
	input clk_i, action_i,

	input wire[15:0] data_i,

	output reg[1:0] state_o,
	output reg[15:0] data_o,

	input wire 			ack_i,
	input wire[15:0]	dat_i,
	
	output reg 			we_o, stb_o, cyc_o,
	output reg[1:0]     sel_o,
	output reg[14:0]	adr_o,
	output reg[15:0]	dat_o
);

enum {ADDR_LATCH, DATA_LATCH, DATA_WRITE} TEST_STATES;

reg[1:0] state, next_state;

reg actionLatch;
reg actionPressed;

// Action Pressed will only be high for a single cycle after action is high
// After that, action must be low for a single cycle before
// action Pressed can be high
assign actionPressed = ~actionLatch & action_i;

initial begin
	state <= ADDR_LATCH;
	actionLatch <= 0;
end

always @ (*) begin
	we_o 	<= 0;
	stb_o 	<= 1;
	cyc_o 	<= 1;
	sel_o 	<= 2'b11;

	state_o <= state;

	case (state) 
		ADDR_LATCH: begin
			if (actionPressed) 
				next_state <= DATA_LATCH;
			else
				next_state <= ADDR_LATCH;
		end
		DATA_LATCH: begin
			if (actionPressed) 
				next_state <= DATA_WRITE;
			else
				next_state <= DATA_LATCH;
		end
		DATA_WRITE: begin
			next_state <= ADDR_LATCH;

			we_o <= 1;
		end
		default: begin
			next_state <= ADDR_LATCH;
		end
	endcase // state
end

always @ (posedge clk_i) begin
	state <= next_state;

	actionLatch <= action_i;

	case (state) 
		ADDR_LATCH: begin
			adr_o 	<= data_i;
			data_o 	<= dat_i;
		end
		DATA_LATCH: begin
			dat_o 	<= data_i;
			data_o 	<= adr_o;
		end
	endcase
end

endmodule