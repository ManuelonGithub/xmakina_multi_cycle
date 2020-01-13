



module xm_cpu_system
#(
	parameter MEM_FILE = "swap_test.mem",
	parameter CLOCK_RATE = 1000
 )
(
	input wire clk_i, // step_i,
    input wire middle_i, left_i, right_i,
//	input wire[2:0] regAdrDbg_i,
    
    input wire[15:0] data_i,
    
    output reg[3:0] state_o,
	output reg[3:0] dispSel_o,
	output reg[6:0] disp_o
);

reg clk;

reg ack, we, stb, cyc;
reg[1:0] sel;
reg[15:0] adr, memDat, cpuDat;

reg memBusy, memWr, statWr;

reg action, cycFwd, cycBwd;
reg view;

reg[15:0] testData, memData, imdr, mdr, mar, regData;
reg debug, regWr, memEn, memWe;
reg[2:0] regAddr;

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

button_press_detector #(.BUTTONS(3)) pressDetector (
	.clk_i   (clk),
	.button_i({middle_i, left_i, right_i}),
	.press_o ({action, cycFwd, cycBwd})
);

xm_debugger debugger (
	.clk_i    (clk),
	.arst_i   (0),
	.action_i (action),
	.cycFwd_i (cycFwd),
	.cycBwd_i (cycBwd),
	.data_i   (data_i),
	.view_o   (view),
	.data_o   (testData),
	.cpuEn_i  (0),
	.pc_i     (16'h1234),
	.reg_i    (0),
	.mem_i    (imdr),
	.debug_o  (debug),
	.regWr_o  (regWr),
	.memEn_o  (memEn),
	.memWe_o  (memWe),
	.regAddr_o(regAddr),
	.state_o  (state_o),
	.memAddr_o(mar),
	.regData_o(regData),
	.memData_o(mdr)
);

memory_controller_unit memoryController (
	.clk_i    (clk_i),
	.rst_i    (arst_i),
	.en_i     (memEn),
	.rw_i     (memWe),
	.pswAddr_i(0),
	.sel_i    (2'b11),
	.addr_i   (mar),
	.data_i   (mdr),
	.psw_i    (0),
	.busy_o   (memBusy),
	.en_o  	  (memWr),
	.pswWr_o  (statWr),
	.data_o   (memData),
	.ack_i    (ack),
	.dat_i    (memDat),
	.we_o     (we),
	.stb_o    (stb),
	.cyc_o    (cyc),
	.sel_o    (sel),
	.adr_o    (adr),
	.dat_o    (cpuDat)
);

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
	.en_i(view),
    .data_i(testData),
    .dispSel_o(dispSel_o),
    .disp_o(disp_o)
);

always @ (posedge clk) begin
	if (memWr)
		imdr <= memData;
end

endmodule