



module xm_cpu_system
#(
	parameter MEM_FILE = "swap_test.mem",
	parameter CLOCK_RATE = 1000
 )
(
	input wire clk_i, // step_i,
    input wire action_i,
//	input wire[2:0] regAdrDbg_i,
    
    input wire[15:0] data_i,
    
    output reg[1:0] state_o,
	output reg[3:0] dispSel_o,
	output reg[6:0] disp_o
);

reg clk;

reg[15:0] testData;

reg ack, we, stb, cyc;
reg[1:0] sel;
reg[15:0] adr, memDat, cpuDat;

//xm_cpu cpu (
//	.clk_i      (clk),
//	.arst_i     (0),
//	.step_i     (step_i),
//	.regAdrDbg_i(regAdrDbg_i),
//	.view_o     (view),
//	.regDbg_o   (regDbg),
//	.ack_i      (ack),
//	.dat_i      (memDat),
//	.we_o       (we),
//	.stb_o      (stb),
//	.cyc_o      (cyc),
//	.sel_o      (sel),
//	.adr_o      (adr),
//	.dat_o      (cpuDat)
//);

mem_wishbone #(.INIT_FILE(MEM_FILE)) memory (
	.clk_i(clk),
	.rst_i(0),
	.we_i (we),
	.stb_i(stb),
	.cyc_i(cyc),
	.sel_i(sel),
	.adr_i(adr),
	.dat_i(cpuDat),
	.ack_o(ack),
	.dat_o(memDat)
);

clock_divider #(.OUTPUT_RATE(CLOCK_RATE)) clockDivider (
	.clk_i(clk_i),
	.clk_o(clk)
);

display_driver displayDriver (
	.clk_i(clk), 
	.en_i(1),
    .data_i(testData),
    .dispSel_o(dispSel_o),
    .disp_o(disp_o)
);

memory_tester memTest (
	.clk_i   (clk),
	.action_i(action_i),
	.data_i  (data_i),
	.state_o (state_o),
	.data_o  (testData),
	.ack_i   (ack),
	.dat_i   (memDat),
	.we_o    (we),
	.stb_o   (stb),
	.cyc_o   (cyc),
	.sel_o   (sel),
	.adr_o   (adr),
	.dat_o   (cpuDat)
);


endmodule