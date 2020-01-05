



module xm_cpu
#(
	parameter WORD = 16
 )
(
	input wire clk_i, arst_i,

	// Bus input signals
	input wire 				ack_i,
	input wire[WORD-1:0]	dat_i,

	// Bus output signals
	output reg 				    we_o, stb_o, cyc_o,
	output reg[1:0]             sel_o,
	output reg[WORD-(WORD/8):0] adr_o,
	output reg[WORD-1:0]        dat_o
);

reg 		memBusy, memWr;
reg 		pcWr, regWr, irWr;
reg 		memEn, memRW;
reg 		byteOp;
reg[1:0]	regWrMode;
reg[2:0] 	regWrAdr, regAdrA, regAdrB;
reg 		pcSel;
reg[15:0] 	memData, branchOffs;

reg[14:0]   mar;
reg[15:0]	omdr, ir;

reg         badMem, pswAddr;
reg[1:0]    datSel;

xm_control_plane control (
	.clk_i       (clk_i),
	.arst_i      (arst_i),
	.memBusy_i   (memBusy),
	.inst_i      (ir),
	.status_i    (0),
	.pcWr_o      (pcWr),
	.regWr_o     (regWr),
	.irWr_o      (irWr),
	.memEn_o     (memEn),
	.memRW_o     (memRW),
	.byteOp_o    (byteOp),
	.regWrMode_o (regWrMode),
	.regWrAdr_o  (regWrAdr),
	.regAdrA_o   (regAdrA),
	.regAdrB_o   (regAdrB),
	.pcSel_o     (pcSel),
	.branchOffs_o(branchOffs)
);

// CPU Datapath
xm_datapath datapath (
	.clk_i       (clk_i),
	.arst_i      (arst_i),
	.pcWr_i      (pcWr),
	.regWr_i     (regWr),
	.memEn_i     (memEn),
	.memWr_i     (memWr),
	.irWr_i      (irWr),
	.byteOp_i    (byteOp),
	.pcSel_i     (pcSel),
	.regWrMode_i (regWrMode),
	.regWrAdr_i  (regWrAdr),
	.regAdrA_i   (regAdrA),
	.regAdrB_i   (regAdrB),
	.mem_i       (memData),
	.branchOffs_i(branchOffs),
	.badMem_o    (badMem),
	.pswAddr_o   (pswAddr),
	.datSel_o    (datSel),
	.mar_o       (mar),
	.omdr_o      (omdr),
	.ir_o        (ir)
);

// Memory Controller
memory_controller_unit memoryController (
	.clk_i (clk_i),
	.rst_i (arst_i),
	.en_i  (memEn),
	.rw_i  (memRW),
	.sel_i (datSel),
	.addr_i(mar),
	.data_i(omdr),
	.busy_o(memBusy),
	.en_o  (memWr),
	.data_o(memData),
	.ack_i (ack_i),
	.dat_i (dat_i),
	.we_o  (we_o),
	.stb_o (stb_o),
	.cyc_o (cyc_o),
	.sel_o (sel_o),
	.adr_o (adr_o),
	.dat_o (dat_o)
);

// Internal Bus arbriter (for Status Register)

endmodule : xm_cpu