



module xm_control_plane
#(
	parameter WORD = 16,
	parameter LR = 5,
	parameter PC = 7
 )
(
	input wire clk_i, arst_i,

	input wire memBusy_i, memWr_i,

	input wire[WORD-1:0] inst_i, status_i,

	// Register file synchrnous control signals
	output reg pcWr_o, regWr_o,

	// Status register synchronous control signals
	output reg clrSlp_o, setPriv_o, flagsWr_o, statWr_o,

	output reg irWr_o, tempWr_o, 

	output reg memEn_o, memRW_o,

	// General operation control signals
	output reg byteOp_o,

	// Register File operation control signals
	output reg[1:0]	regWrMode_o,
	output reg[2:0] regWrAdr_o, regAdrA_o, regAdrB_o,

	// ALU operand source selection signals 
	output reg aluBRegSel_o, aluBConstSel_o, aluBOffsetSel_o,
	// ALU operation control signals
	output reg[3:0] aluOp_o,

	// Status Register operation control & input signals
	output reg[1:0] statWrMode_o,
	output reg[2:0] priv_o,
	output reg[3:0] flagsEn_o,

	// Memory Address Register source selection signals
	output reg adrPcSel_o, adrAluSel_o, adrBaseSel_o,
    
    // PSW Fetch enable signal
    // If enabled, it routes the PSW to the in/out memory registers
    output reg pswSel_o,

	// PC offset selecion signal
	output reg pcSel_o,

	// Register Write selection signals 
	output reg regAluSel_o, regAddrSel_o, regMemSel_o, regTempSel_o, regPcSel_o, regImmSel_o,

	output reg[15:0] branchOffs_o, memOffs_o, immVal_o
);

localparam FLAGS_L  = 0;
localparam FLAGS_H  = 3;

reg decEn;

wire irWr = decEn & memWr_i;

reg IbyteOp, IconstSel, IbranchRes, IbcdEn;
reg[1:0] IaluWrMode, IimmWrMode, ImemWrMode;
reg[2:0] IregAdrA, IregAdrB;
reg[3:0] IaluOp, IflagsEn;
reg[4:0] instOp;
reg[WORD-1:0] IimmVal, IcondOffset, IjumpOffset, IaccOffset, IrelOffset;

// Instruction register/Decoder
xm_inst_decoder #(.WORD(WORD), .LR(LR), .PC(PC)) decoder (
	.clk_i       (clk_i),
	.arst_i      (arst_i),
	.en_i        (irWr),
	.flags_i     (status_i[FLAGS_H:FLAGS_L]),
	.inst_i      (inst_i),
	.byteOp_o    (IbyteOp),
	.constSel_o  (IconstSel),
	.branchRes_o (IbranchRes),
	.bcdEn_o     (IbcdEn),
	.aluWrMode_o (IaluWrMode),
	.immWrMode_o (IimmWrMode),
	.memWrMode_o (ImemWrMode),
	.regAdrA_o   (IregAdrA),
	.regAdrB_o   (IregAdrB),
	.instOp_o    (instOp),
	.aluOp_o     (IaluOp),
	.flagsEn_o   (IflagsEn),
	.immVal_o    (IimmVal),
	.condOffset_o(IcondOffset),
	.jumpOffset_o(IjumpOffset),
	.accOffset_o (IaccOffset),
	.relOffset_o (IrelOffset)
);

// CPU Controller
xm_controller #(.WORD(WORD), .LR(LR), .PC(PC)) controller (
	.clk_i          (clk_i),
	.arst_i         (arst_i),
	.memBusy_i      (memBusy_i),
	.byteOp_i       (IbyteOp),
	.constSel_i     (IconstSel),
	.branchRes_i    (IbranchRes),
	.bcdEn_i        (IbcdEn),
	.aluWrMode_i    (IaluWrMode),
	.immWrMode_i    (IimmWrMode),
	.memWrMode_i    (ImemWrMode),
	.regAdrA_i       (IregAdrA),
	.regAdrB_i      (IregAdrB),
	.instOp_i       (instOp),
	.aluOp_i        (IaluOp),
	.flagsEn_i      (IflagsEn),
	.immVal_i       (IimmVal),
	.condOffset_i   (IcondOffset),
	.jumpOffset_i   (IjumpOffset),
	.accOffset_i    (IaccOffset),
	.relOffset_i    (IrelOffset),
	.pcWr_o         (pcWr_o),
	.regWr_o        (regWr_o),
	.clrSlp_o       (clrSlp_o),
	.setPriv_o      (setPriv_o),
	.flagsWr_o      (flagsWr_o),
	.statWr_o       (statWr_o),
	.decEn_o        (decEn),
	.tempWr_o       (tempWr_o),
	.memEn_o        (memEn_o),
	.memRW_o        (memRW_o),
	.byteOp_o       (byteOp_o),
	.regWrMode_o    (regWrMode_o),
	.regWrAdr_o     (regWrAdr_o),
	.regAdrA_o      (regAdrA_o),
	.regAdrB_o      (regAdrB_o),
	.aluBRegSel_o   (aluBRegSel_o),
	.aluBConstSel_o (aluBConstSel_o),
	.aluBOffsetSel_o(aluBOffsetSel_o),
	.aluOp_o        (aluOp_o),
	.statWrMode_o   (statWrMode_o),
	.priv_o         (priv_o),
	.flagsEn_o      (flagsEn_o),
	.adrPcSel_o     (adrPcSel_o),
	.adrAluSel_o    (adrAluSel_o),
	.adrBaseSel_o   (adrBaseSel_o),
	.pswSel_o       (pswSel_o),
	.pcSel_o        (pcSel_o),
	.regAluSel_o    (regAluSel_o),
	.regAddrSel_o   (regAddrSel_o),
	.regMemSel_o    (regMemSel_o),
	.regTempSel_o   (regTempSel_o),
	.regPcSel_o     (regPcSel_o),
	.regImmSel_o    (regImmSel_o),
	.branchOffs_o   (branchOffs_o),
	.memOffs_o      (memOffs_o),
	.immVal_o       (immVal_o)	
);

endmodule