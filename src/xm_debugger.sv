



module xm_debugger
(
	input wire clk_i, 
	input wire ctrlEn_i, step_i,

	output reg halt_o, view_o
);
 
enum {DEBUG, RUN, STALL_WAIT} RUN_STATES;

reg[1:0] run_state, next_state;

reg debugEn;

initial begin
	run_state <= DEBUG;
end

always @ (*) begin
    halt_o 	<= 1;
    debugEn <= 0;
    
	case (run_state)
		DEBUG: begin
			if (step_i) 
				next_state <= RUN;
			else
				next_state <= HALT;

			debugEn <= 1;
		end

		RUN: begin
			next_state <= EDGE_STALL;

			halt_o 	<= 0;
		end

		EDGE_STALL: begin
			if (step_i || ctrlEn_i) 
				next_state <= EDGE_STALL;
			else
				next_state <= DEBUG;

			halt_o 	<= 0;
		end
	default: begin
	   next_state <= DEBUG;
	end
	endcase // run_state
end

always @ (posedge clk_i) begin
	run_state <= next_state;
end

endmodule