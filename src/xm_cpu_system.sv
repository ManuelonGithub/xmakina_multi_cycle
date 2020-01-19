



module xm_cpu_system
#(
	parameter MEM_FILE = "swap_test.mem",
	parameter CLOCK_RATE = 1000
 )
(
	input wire clk_i,
    input wire action_i, 
    
    input wire[15:0] data_i,
    
    output reg[15:0] data_o,
	output reg[3:0] dispSel_o,
	output reg[6:0] disp_o
);

reg clk;

reg ack, we, stb, cyc;
reg[1:0] sel;
reg[15:0] adr, ExtDat, cpuDat;

reg memBusy, memWr, statWr;

reg[1:0] slvAck, slvStb, slvCyc;
reg[15:0] arb0Adr, memDat, dispDat;

memory_tester memTest (
	.clk_i   (clk_i),
	.action_i(action_i),
	.data_i  (data_i),
	.data_o  (data_o),
	.ack_i   (ack),
	.dat_i   (ExtDat),
	.we_o    (we),
	.stb_o   (stb),
	.cyc_o   (cyc),
	.sel_o   (sel),
	.adr_o   (adr),
	.dat_o   (cpuDat)
);

//mem_wishbone #(.INIT_FILE(MEM_FILE), .BYTES(4096)) memory (
//	.clk_i(clk),
//	.rst_i(0),
//	.we_i (we),
//	.stb_i(slvStb[0]),
//	.cyc_i(slvCyc[0]),
//	.sel_i(sel),
//	.adr_i(arb0Adr),
//	.dat_i(cpuDat),
//	.ack_o(slvAck[0]),
//	.dat_o(memDat)
//);

//wb_segment_display display (
//	.clk_i    (clk),
//	.rst_i    (0),
//	.stb_i    (slvStb[1]),
//	.cyc_i    (slvCyc[1]),
//	.we_i     (we),
//	.sel_i    (sel),
//	.dat_i    (cpuDat),
//	.ack_o    (slvAck[1]),
//	.dat_o    (dispDat),
//	.dispSel_o(dispSel_o),
//	.disp_o   (disp_o)
//);
	

//WBbus_slave_arbitrer #(.SLAVES(2), .SEL_H($clog2(4096))) arbiter0 (
//	.stb_i   (stb),
//	.cyc_i   (cyc),
//	.slvAck_i(slvAck),
//	.adr_i   (adr),
//	.slvDat_i({memDat, dispDat}),
//	.ack_o   (ack),
//	.slvStb_o(slvStb),
//	.slvCyc_o(slvCyc),
//	.dat_o   (ExtDat),
//	.adr_o   (arb0Adr)	
//);

wb_segment_display display (
	.clk_i    (clk),
	.rst_i    (0),
	.stb_i    (stb),
	.cyc_i    (cyc),
	.we_i     (we),
	.sel_i    (sel),
	.dat_i    (cpuDat),
	.ack_o    (ack),
	.dat_o    (ExtDat),
	.dispSel_o(dispSel_o),
	.disp_o   (disp_o)
);

clock_divider #(.OUTPUT_RATE(CLOCK_RATE)) clockDivider (
	.clk_i(clk_i),
	.clk_o(clk)
);

endmodule