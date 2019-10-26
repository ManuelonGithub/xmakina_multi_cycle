/**
 * @File    X-Makina External Bus Interfacer Module file.
 * @brief   Contains the code for the X-Makina External Bus Interfacer module.
 * @author  Manuel Burnay
 * @date    2019.10.26 (created)
 * @date    2019.10.26 (Last Modified)
 */


module Bus_interfacer
#(
	parameter ACTIVE_EDGE = 1,
	parameter USE_DONE_SIGNAL = 0,
	parameter WORD = 16
 )
(
	input wire clk, reset, en, read_or_write,
	input wire[$clog2(WORD/8)-1:0] size,
	input wire[WORD-1:0] addr, wr_data,

	input wire BUS_rd_done, BUS_wr_done, BUS_rd_err, BUS_wr_err,
	input wire[WORD-1:0] BUS_rd_data,

	output reg BUS_rd_en, BUS_wr_en,
	output reg[$clog2(WORD/8)-1:0] size,
	output reg [WORD-1:0] BUS_rd_addr, BUS_wr_addr, BUS_wr_data,

	output reg ready, bad_addr, rd_err, wr_err,

	output reg[WORD-1:0] rd_data
);

	localparam BYTE = 8;
	localparam MAX_BYTES = WORD/8;

	enum {IDLE, RD_ACCESS, WRITE_ACCESS, STATES} BUS_STATES;

	reg rd_data_en, wr_data_en, read_addr;
	reg[$clog2(STATES)-1:0] state, next_state;

	reg[WORD-1:0] addr_R, data_R;

	wire rd_done = (BUS_rd_done | ~USE_DONE_SIGNAL);
	wire wr_done = (BUS_wr_done | ~USE_DONE_SIGNAL);

	initial begin
		data_R <= 0;
		addr_R <= 0;
	end

	always @ (*) begin
		bad_addr <= (MAX_BYTES - addr_R[$clog2(WORD/8)-1:0]) < size;
		rd_err 	<= BUS_rd_err;
		wr_err 	<= BUS_wr_err;

		BUS_rd_addr <= addr_R;
		BUS_wr_addr <= addr_R;
		rd_data <= data_R;

		case (state)
			IDLE: begin
				read_addr <= 1;		// Register address word into addr_R
				rd_data_en <= 0;	// Do not register the bus
				wr_data_en <= 1;	// Register write word into data_R

				ready <= 1;			// Tell the machine the interfacer is ready to perform an access to bus.

				BUS_rd_en <= 0;
				BUS_wr_en <= 0;

				next_state <= IDLE;

				if (en && ~bad_BUS) begin
					ready <= 0;

					if (read_or_write) begin	// The machine is requesting a read access
						BUS_rd_en <= 1;
						next_state <= READ_ACCESS;
					end
					else begin		// The machine is requesting a write access
						BUS_wr_en <= 1;
						next_state <= WRITE_ACCESS;
					end
				end
			end
			READ_ACCESS: begin
				rd_data_en <= 1;	// Register the bus
				wr_data_en <= 0;
				read_addr <= 0;

				ready <= 0;
				BUS_rd_en <= 1;
				BUS_wr_en <= 0;

				next_state <= READ_ACCESS;

				if (rd_done) begin
					ready <= 1;
					BUS_rd_en <= 0;

					next_state <= IDLE;
				end
			end
			WRITE_ACCESS: begin
				rd_data_en <= 0;
				wr_data_en <= 0;
				read_addr <= 0;

				ready <= 0;
				BUS_rd_en <= 0;
				BUS_wr_en <= 1;

				next_state <= WRITE_ACCESS;

				if (wr_done) begin
					ready <= 1;
					BUS_wr_en <= 0;

					next_state <= IDLE;
				end
			end
		endcase // state
	end

	generate
		if (ACTIVE_EDGE) begin

			always @ (posedge(clk) or posedge(reset)) begin
				if (reset) begin
					data_R <= 0;
					addr_R <= 0;
					state <= IDLE;
				end
				else begin
					if (read_addr) 	addr_R <= addr;
					if (wr_data_en) data_R <= wr_data;
					if (rd_data_en) data_R <= 	BUS_rd_data;

					state <= next_state;
				end
			end

		end
		else begin

			always @ (posedge(clk) or posedge(reset)) begin
				if (reset) begin
					data_R <= 0;
					addr_R <= 0;
					state <= IDLE;
				end
				else begin
					if (read_addr) 	addr_R <= addr;
					if (wr_data_en) data_R <= wr_data;
					if (rd_data_en) data_R <= 	BUS_rd_data;

					state <= next_state;
				end
			end

		end
	endgenerate

endmodule : BUSory_interfacer