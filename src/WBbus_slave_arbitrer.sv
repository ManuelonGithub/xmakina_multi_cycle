



module WBbus_slave_arbitrer 
#(
	parameter WORD = 16,
	parameter SEL_H = WORD-1,
	parameter SLAVES = 4
 )
(
	input wire stb_i, cyc_i,
	input wire[SLAVES-1:0] slvAck_i,
	input wire[WORD-1:0] adr_i,
	input wire[WORD-1:0] slvDat_i[SLAVES],

	output reg ack_o,
	output reg[SLAVES-1:0] slvStb_o, slvCyc_o,
	output reg[WORD-1:0] dat_o, adr_o
);

localparam SEL_L = (SEL_H + 1 - $clog2(SLAVES));
localparam ADDR_H = SEL_L - 1;

wire[SLAVES-1:0] sel = adr_i[SEL_H:SEL_L];


always @ (*) begin
	ack_o <= slvAck_i[sel];

	slvStb_o <= 0;
	slvStb_o[sel] <= stb_i;

	slvCyc_o <= 0;
	slvCyc_o[sel] <= cyc_i;

	dat_o <= slvDat_i[sel];

	adr_o <= 0;
	adr_o <= adr_i[ADDR_H:0];
end

endmodule 