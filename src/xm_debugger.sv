



module xm_debugger
(
	input wire clk_i, arst_i,

	// Interface connections
	input wire action_i, cycFwd_i, cycBwd_i,

	input wire[15:0] data_i,

	output reg view_o,
	output reg[15:0] data_o,

	// CPU connections
	input wire ctrlEn_i,
	input wire[15:0] pc_i, reg_i, mem_i,

	output reg debug_o,
	output reg regWr_o, memEn_o, memWe_o,
	output reg[2:0] regAddr_o,
	output reg[15:0] memAddr_o, regData_o, memData_o
);
 
enum {PROG_VIEW, PROG_STEP, PROG_HOLD, REG_VIEW, REG_WRITE, REG_HOLD, MEM_VIEW, MEM_WRITE, MEM_HOLD} RUN_STATES;

reg[3:0] state, next_state;

initial begin
	state 		<= PROG_VIEW;
	data_o 		<= 0;
	regAddr_o 	<= 0;
	memAddr_o	<= 0;
	regData_o	<= 0;
	memData_o	<= 0;
end

always @ (*) begin
	view_o 	<= 1;
	debug_o <= 1;
	regWr_o <= 0;
	memEn_o <= 0;
	memWe_o <= 0;

	case (state)
		PROG_VIEW: begin
			if (action_i)
				next_state <= PROG_STEP;
			else if (cycFwd_i)
				next_state <= REG_VIEW;
			else if (cycFwd_i)
				next_state <= MEM_VIEW;
			else
				next_state <= PROG_VIEW;

			data_o <= pc_i;
		end
		PROG_STEP: begin
			next_state <= PROG_HOLD;

			data_o <= pc_i;
			view_o 	<= 0;
			debug_o <= 0;
		end
		PROG_HOLD: begin
			next_state <= PROG_HOLD;

			data_o <= pc_i;
			view_o 	<= 0;
			debug_o <= 0;
		end
		REG_VIEW: begin

		end
		REG_WRITE: begin

		end
		REG_HOLD: begin

		end
		MEM_VIEW: begin

		end
		MEM_WRITE: begin

		end
		MEM_HOLD: begin

		end
		default: begin
			next_state <= PROG_VIEW;
		end
	endcase // state
end

always @ (posedge clk_i, posedge arst_i) begin
	if (arst_i) 
		state <= PROG_VIEW;
	else
		state <= next_state;
end

endmodule