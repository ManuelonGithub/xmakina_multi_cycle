



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
	output reg pcWr_o, regWr_o, irWr_o, flagsWr_o, tempWr_o,

	output reg memEn_o, memRW_o,

	// General operation control signals
	output reg byteOp_o, pcSel_o,

	output reg[1:0]	aluBSel_o, adrSel_o,
	
	// Register File operation control signals
	output reg[1:0]	regWrMode_o,
	output reg[2:0] regWrSel_o,
	output reg[2:0] regWrAdr_o, regAdrA_o, regAdrB_o,

	output reg[3:0] aluOp_o,
	output reg[3:0] flagsEn_o,

	output reg[15:0] branchOffs_o, immVal_o, memOffs_o
);

localparam FLAGS_L  = 0;
localparam FLAGS_H  = 3;

reg IbyteOp, IconstSel, IbranchRes, IbcdEn, IpreAcc;
reg[1:0] IaluWrMode, IimmWrMode, ImemWrMode;
reg[2:0] IregAdrA, IregAdrB;
reg[3:0] IaluOp, IflagsEn;
reg[4:0] instOp;
reg[WORD-1:0] IimmVal, IcondOffset, IlinkOffset, IaccOffset, IrelOffset;

// Instruction register/Decoder
xm_inst_decoder #(.WORD(WORD), .LR(LR), .PC(PC)) decoder (
	.flags_i     (status_i[FLAGS_H:FLAGS_L]),
	.inst_i      (inst_i),
	.byteOp_o    (IbyteOp),
	.constSel_o  (IconstSel),
	.branchRes_o (IbranchRes),
	.bcdEn_o     (IbcdEn),
	.preAcc_o    (IpreAcc),
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
	.linkOffset_o(IlinkOffset),
	.accOffset_o (IaccOffset),
	.relOffset_o (IrelOffset)
);

// CPU Controller
xm_controller #(.WORD(WORD), .LR(LR), .PC(PC)) controller (
	.clk_i       (clk_i),
	.arst_i      (arst_i),
	.memBusy_i   (memBusy_i),
	.memWr_i     (memWr_i),
	.byteOp_i    (IbyteOp),
	.constSel_i  (IconstSel),
	.branchRes_i (IbranchRes),
	.bcdEn_i     (IbcdEn),
	.preAcc_i    (IpreAcc),
	.aluWrMode_i (IaluWrMode),
	.immWrMode_i (IimmWrMode),
	.memWrMode_i (ImemWrMode),
	.regAdrA_i   (IregAdrA),
	.regAdrB_i   (IregAdrB),
	.instOp_i    (instOp),
	.aluOp_i     (IaluOp),
	.flagsEn_i   (IflagsEn),
	.immVal_i    (IimmVal),
	.condOffset_i(IcondOffset),
	.linkOffset_i(IlinkOffset),
	.accOffset_i (IaccOffset),
	.relOffset_i (IrelOffset),
	.pcWr_o      (pcWr_o),
	.regWr_o     (regWr_o),
	.memEn_o     (memEn_o),
	.irWr_o      (irWr_o),
	.flagsWr_o   (flagsWr_o),
	.tempWr_o    (tempWr_o),
	.byteOp_o    (byteOp_o),
	.memRW_o     (memRW_o),
	.pcSel_o     (pcSel_o),
	.aluBSel_o   (aluBSel_o),
	.adrSel_o    (adrSel_o),
	.regWrMode_o (regWrMode_o),
	.regWrSel_o  (regWrSel_o),
	.regWrAdr_o  (regWrAdr_o),
	.regAdrA_o   (regAdrA_o),
	.regAdrB_o   (regAdrB_o),
	.aluOp_o     (aluOp_o),
	.flagsEn_o   (flagsEn_o),
	.branchOffs_o(branchOffs_o),
	.immVal_o    (immVal_o),
	.memOffs_o   (memOffs_o)
);

endmodule