



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
reg 		pcWr, regWr, irWr, flagsWr;
reg 		memEn, memRW;
reg 		byteOp;
reg 		pcSel;
reg[1:0] 	aluBSel, adrSel;
reg[1:0]	regWrMode;
reg[2:0]    regWrSel;
reg[2:0] 	regWrAdr, regAdrA, regAdrB;
reg[3:0]	aluOp;
reg[3:0]	flagsEn;
reg[14:0]   mar;
reg[15:0]	omdr, ir, status;
reg[15:0] 	memData, branchOffs, immVal, memOffs;

reg 		statWr;
reg[1:0] 	statWrMode;

reg         badMem, pswAddr;
reg[1:0]    datSel;

xm_control_plane control (
	.clk_i       (clk_i),
	.arst_i      (arst_i),
	.memBusy_i   (memBusy),
	.memWr_i     (memWr),
	.inst_i      (ir),
	.status_i    (status),
	.pcWr_o      (pcWr),
	.regWr_o     (regWr),
	.irWr_o      (irWr),
	.flagsWr_o   (flagsWr),
	.memEn_o     (memEn),
	.memRW_o     (memRW),
	.byteOp_o    (byteOp),
	.pcSel_o     (pcSel),
	.aluBSel_o   (aluBSel),
	.adrSel_o    (adrSel),
	.regWrMode_o (regWrMode),
	.regWrSel_o  (regWrSel),
	.regWrAdr_o  (regWrAdr),
	.regAdrA_o   (regAdrA),
	.regAdrB_o   (regAdrB),
	.aluOp_o     (aluOp),
	.flagsEn_o   (flagsEn),
	.branchOffs_o(branchOffs),
	.immVal_o    (immVal),
	.memOffs_o   (memOffs)
);

// CPU Datapath
xm_datapath datapath (
	.clk_i       (clk_i),
	.arst_i      (arst_i),
	.pcWr_i      (pcWr),
	.regWr_i     (regWr),
	.memEn_i     (memEn),
	.irWr_i      (irWr),
	.statWr_i    (statWr),
	.flagsWr_i   (flagsWr),
	.byteOp_i    (byteOp),
	.pcSel_i     (pcSel),
	.aluBSel_i   (aluBSel),
	.adrSel_i    (adrSel),
	.statWrMode_i(sel_o),
	.regWrMode_i (regWrMode),
	.regWrSel_i  (regWrSel),
	.regWrAdr_i  (regWrAdr),
	.regAdrA_i   (regAdrA),
	.regAdrB_i   (regAdrB),
	.aluOp_i     (aluOp),
	.flagsEn_i   (flagsEn),
	.mem_i       (memData),
	.branchOffs_i(branchOffs),
	.immVal_i    (immVal),
	.memOffs_i   (memOffs),
	.badMem_o    (badMem),
	.pswAddr_o   (pswAddr),
	.datSel_o    (datSel),
	.mar_o       (mar),
	.omdr_o      (omdr),
	.ir_o        (ir),
	.status_o    (status)
);

// Memory Controller
memory_controller_unit memoryController (
	.clk_i    (clk_i),
	.rst_i    (arst_i),
	.en_i     (memEn),
	.rw_i     (memRW),
	.pswAddr_i(pswAddr),
	.sel_i    (datSel),
	.addr_i   (mar),
	.data_i   (omdr),
	.psw_i    (status),
	.busy_o   (memBusy),
	.en_o  	  (memWr),
	.pswWr_o  (statWr),
	.data_o   (memData),
	.ack_i    (ack_i),
	.dat_i    (dat_i),
	.we_o     (we_o),
	.stb_o    (stb_o),
	.cyc_o    (cyc_o),
	.sel_o    (sel_o),
	.adr_o    (adr_o),
	.dat_o    (dat_o)
);

// Internal Bus arbriter (for Status Register)

endmodule : xm_cpu