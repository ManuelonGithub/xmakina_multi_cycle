/**
 */


 module Fetch_unit
#(
	parameter ACTIVE_EDGE = 1,
	parameter USE_DONE_SIGNAL = 0,
	parameter WORD = 16
 )
(
	input wire clk, reset, en,
	input wire[WORD-1:0] addr,

	input wire ROM_done, ROM_err,
	input wire[WORD-1:0] ROM_data,

	output reg ROM_en,
	output reg [WORD-1:0] ROM_addr,

	output reg ready, bad_mem, exc_ret, err,

	output reg[WORD-1:0] inst
);

	localparam BYTE = 8;
	localparam MAX_BYTES = WORD/8;

	enum {IDLE, ACCESS, STATES} FETCH_STATES;

	reg read_rom, read_addr;
	reg[$clog2(STATES)-1:0] state, next_state;

	wire fetch_done = (ROM_done | ~USE_DONE_SIGNAL);

	initial begin
		ROM_addr <= 0;
		inst <= 0;
	end

	always @ (*) begin
		bad_mem <= |ROM_addr[$clog2(MAX_BYTES)-1:0];
		exc_ret <= |ROM_addr;
		err 	<= ROM_err;

		case (state)
			IDLE: begin
				read_rom <= 0;
				read_addr <= 1;

				ready <= 1;
				ROM_en <= 0;
				next_state <= IDLE;

				if (en && ~bad_mem) begin
					ready <= 0;
					ROM_en <= 1;

					next_state <= ACCESS;
				end
			end
			ACCESS: begin
				read_rom <= 1;
				read_addr <= 0;

				ready <= 0;
				ROM_en <= 1;
				next_state <= ACCESS;

				if (fetch_done) begin
					ready <= 1;
					ROM_en <= 0;

					next_state <= IDLE;
				end
			end
		endcase // state
	end

	generate
		if (ACTIVE_EDGE) begin

			always @ (posedge(clk) or posedge(reset)) begin
				if (reset) begin
					ROM_addr <= 0;
					inst <= 0;
				end
				else begin
					if (read_addr) 	ROM_addr <= addr;
					if (read_rom) 	inst <= ROM_data;

					state <= next_state;
				end
			end

		end
		else begin

			always @ (negedge(clk) or posedge(reset)) begin
				if (reset) begin
					ROM_addr <= 0;
					inst <= 0;
				end
				else begin
					if (read_addr) 	ROM_addr <= addr;
					if (read_rom) 	inst <= ROM_data;

					state <= next_state;
				end
			end

		end
	endgenerate

endmodule : Fetch_unit