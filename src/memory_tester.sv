



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

enum {ADDR_LATCH, ACTION_STALL, DATA_LATCH, DATA_WRITE} TEST_STATES;

reg[2:0] state, next_state;

initial begin
	state <= ADDR_LATCH;
end

always @ (*) begin
	we_o 	<= 0;
	stb_o 	<= 1;
	cyc_o 	<= 1;
	sel_o 	<= 2'b11;

	state_o <= state;

	case (state) 
		ADDR_LATCH: begin
			if (action_i) 
				next_state <= ACTION_STALL;
			else
				next_state <= ADDR_LATCH;
		end
		ACTION_STALL: begin
			if (~action_i) 
				next_state <= DATA_LATCH;
			else
				next_state <= ACTION_STALL;
		end
		DATA_LATCH: begin
			if (action_i) 
				next_state <= DATA_WRITE;
			else
				next_state <= DATA_LATCH;
		end
		DATA_WRITE: begin
			if (~action_i) 
				next_state <= ADDR_LATCH;
			else
				next_state <= DATA_WRITE;

			we_o <= 1;
		end
		default: begin
			next_state <= ADDR_LATCH;
		end
	endcase // state
end

always @ (posedge clk_i) begin
	state <= next_state;

	case (state) 
		ADDR_LATCH: begin
			adr_o 	<= data_i;
			data_o 	<= dat_i;
		end
		DATA_LATCH: begin
			dat_o 	<= data_i;
			data_o 	<= data_i;
		end
	endcase
end

endmodule