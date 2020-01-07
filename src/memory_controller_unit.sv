

// Memory controller: (wishbone master)
// 	internal signals:
// 		control:
// 			cmd_i  -> 3-bit signal:
// 				| r/w | byte sel |
// 				|  0  |  0    0  |	-> res
// 				|  0  |  0    1  |  -> Read address' low byte
// 				|  0  |  1    0  |  -> read address' high byte
// 				|  0  |  1    1  |  -> Adress address word
// 				|  1  |  0    0  |	-> res
// 				|  1  |  0    1  |  -> Write address' low byte
// 				|  1  |  1    0  |  -> Write address' high byte
// 				|  1  |  1    1  |  -> Write address word
// 			en_i   -> when asserted it starts a data transfer cycle. Ignored while busy_o is asserted.

// 			busy_o -> Asserted while controller is in a transfer cycle
// 		datapath:
// 			addr_i -> 15-bit ; Data transfer address
// 			data_i -> 16-bit ; Write transfer data
			
// 			data_o -> 16-bit ; Read Transfer data
// 	Bus signals:
// 		control:
// 			we_o  -> 0 = read transfer, 1 = write transfer
// 			sel_o -> 2-bit signal: selects which byte lane is active/valid in a transfer
// 			stb_o -> strobe signal. Asserted to enable a data transfer phase *
// 			ack_i -> Asswerted when the slave has finished its side of the data transfer
// 			cyc_o -> Cycle signal. Asserted to enable a data tansfer cycle *

// 			*****
// 				there can be many phases in a single D.T. cycle. 
// 				For a single D.T. (read or write), 
// 				STB & CYC are asserted at the same time & for the same duration.
// 			*****
//		datapath:
// 			adr_o -> 15-buts ; data transfer address 
// 			dat_i -> data from slave (read)
// 			dat_o -> data to slave (write)

module memory_controller_unit
#(
	parameter WORD = 16
 )
(
	// System connection signals 
	input wire 	clk_i, rst_i, 

	// internal signals
	input wire 					en_i, rw_i, pswAddr_i,
	input wire[1:0]				sel_i,
	input wire[WORD-(WORD/8):0] addr_i,
	input wire[WORD-1:0]		data_i, psw_i,

	output reg					busy_o, en_o, pswWr_o,
	output reg[WORD-1:0]		data_o,

	// Bus signals
	input wire 					ack_i,
	input wire[WORD-1:0]		dat_i,
	
	output reg 					we_o, stb_o, cyc_o,
	output reg[1:0]         	sel_o,
	output reg[WORD-(WORD/8):0]	adr_o,
	output reg[WORD-1:0]		dat_o
);

localparam HALF_WORD = WORD/2;

enum {LB, HB, RW} COMMAND_BITS;
enum {READ_EN, WRITE_EN} TRANSFER_TYPES;
enum {IDLE, READ, WRITE} CYCLE_STATES;

reg[1:0] state = IDLE, next_state;

reg[WORD-1:0] memData;

assign stb_o = cyc_o;
assign cyc_o = busy_o;

always @ (*) begin
	we_o <= 1'b0;
	busy_o <= 1'b0;
	en_o <= 1'b0;

	case (state)
		IDLE: begin
			if (en_i) begin
				if (rw_i)	next_state <= WRITE;
				else		next_state <= READ;
			end else		next_state <= IDLE; 
		end
		READ: begin
			busy_o <= 1'b1;
			en_o <= 1'b1;
			
			if (ack_i || pswAddr_i) 	
				next_state <= IDLE;
			else		
				next_state <= READ;
		end
		WRITE: begin
			busy_o <= 1'b1;
			we_o <= 1'b1;

			if (ack_i || pswAddr_i) 
				next_state <= IDLE;
			else		
				next_state <= WRITE;
		end
		default : next_state <= IDLE;
	endcase
end

always @ (*) begin
    adr_o <= addr_i;
    dat_o <= data_i;
    sel_o <= sel_i;

    pswWr_o <= pswAddr_i & we_o;

    if (pswAddr_i)
    	memData <= psw_i;
    else
    	memData <= dat_i;
    
    case (sel_o)
        2'b01:      data_o <= {{WORD/2{1'b0}}, memData[WORD/2-1:0]};
        2'b10:      data_o <= {memData[WORD-1:WORD/2], {WORD/2{1'b0}}};
        default:    data_o <= memData;
    endcase
end

always @ (posedge clk_i) begin
	if (rst_i)	state <= IDLE;
	else		state <= next_state;
end

 
endmodule