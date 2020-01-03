



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
	output reg 				we_o, stb_o, cyc_o,
	output reg[1:0]         sel_o,
	output reg[WORD-1:0]	adr_o, dat_o
);

reg 		pcWr, regWr;
reg 		clrSlp, setPriv, flagsWr, statWr;
reg 		irWr, tempWr;
reg 		memEn, memRW;
reg 		byteOp;
reg[1:0]	regWrMode;
reg[2:0] 	regWrAdr, regAdrA, regAdrB;
reg 		aluBRegSel, aluBConstSel, aluBOffsetSel;
reg[3:0] 	aluOp;
reg[1:0] 	statWrMode;
reg[2:0] 	priv;
reg[3:0] 	flagsEn;
reg 		adrPcSel, adrAluSel, adrBaseSel;
reg 		pcSel;
reg 		regAluSel, regAddrSel, regMemSel, regTempSel, regPcSel, regImmSel;
reg[15:0] 	branchOffs, memOffs, immVal;

xm_control_plane control (
	.clk_i          (clk_i),
	.arst_i         (arst_i),
	.memBusy_i      (memBusy),
	.memWr_i        (memWr),
	.inst_i         (dat_i),
	.status_i       (status),
	.pcWr_o         (pcWr),
	.regWr_o        (regWr),
	.clrSlp_o       (clrSlp),
	.setPriv_o      (setPriv),
	.flagsWr_o      (flagsWr),
	.statWr_o       (statWr),
	.irWr_o         (irWr),
	.tempWr_o       (tempWr),
	.memEn_o        (memEn),
	.memRW_o        (memRW),
	.byteOp_o       (byteOp),
	.regWrMode_o    (regWrMode),
	.regWrAdr_o     (regWrAdr),
	.regAdrA_o      (regAdrA),
	.regAdrB_o      (regAdrB),
	.aluBRegSel_o   (aluBRegSel),
	.aluBConstSel_o (aluBConstSel),
	.aluBOffsetSel_o(aluBOffsetSel),
	.aluOp_o        (aluOp),
	.statWrMode_o   (statWrMode),
	.priv_o         (priv),
	.flagsEn_o      (flagsEn),
	.adrPcSel_o     (adrPcSel),
	.adrAluSel_o    (adrAluSel),
	.adrBaseSel_o   (adrBaseSel),
	.pswSel_o       (pswSel),
	.pcSel_o        (pcSel),
	.regAluSel_o    (regAluSel),
	.regAddrSel_o   (regAddrSel),
	.regMemSel_o    (regMemSel),
	.regTempSel_o   (regTempSel),
	.regPcSel_o     (regPcSel),
	.regImmSel_o    (regImmSel),
	.branchOffs_o   (branchOffs),
	.memOffs_o      (memOffs),
	.immVal_o       (immVal)
);

// CPU Datapath
xm_datapath datapath (
	.clk_i          (clk_i),
	.arst_i         (arst_i),
	.pcWr_i         (pcWr),
	.regWr_i        (regWr),
	.tempWr_i       (tempWr),
	.byteOp_i       (byteOp),
	.regWrMode_i    (regWrMode),
	.regWrAdr_i     (regWrAdr),
	.regAdrA_i      (regAdrA),
	.regAdrB_i      (regAdrB),
	.aluBRegSel_i   (aluBRegSel),
	.aluBConstSel_i (aluBConstSel),
	.aluBOffsetSel_i(aluBOffsetSel),
	.aluOp_i        (aluOp),
	.pcSel_i        (pcSel),
	.adrPcSel_i     (adrPcSel),
	.adrAluSel_i    (adrAluSel),
	.adrBaseSel_i   (adrBaseSel),
	.regAluSel_i    (regAluSel),
	.regAddrSel_i   (regAddrSel),
	.regMemSel_i    (regMemSel),
	.regTempSel_i   (regTempSel),
	.regPcSel_i     (regPcSel),
	.regImmSel_i    (regImmSel),
	.mem_i          (memData),
	.branchOffs_i   (branchOffs),
	.memOffs_i      (memOffs),
	.immVal_i       (immVal),
	.addr_o         (dataAdr),
	.mem_o          (dataOut)
);

// Memory Controller

// Internal Bus arbriter (for Status Register)

endmodule : xm_cpu