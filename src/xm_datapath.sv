/*
 * file: xm_datapath.sv
 * author: Manuel Burnay
 * date created: 2019.12.22
 */

/*
 * X-Makina datapath module.
 * Contains all data components and data selection entities,
 * that are required to perform all operations required out of the processor,
 * as per the specifications of the X-Makina ISA.
 */
module xm_datapath
#(
	parameter WORD = 16
 )
(
	// System inputs
	input wire clk_i, arst_i, 

	// Synchronous Control signals 
	// these signals are what the controller directly handles

	// Register file synchrnous control signals
	input wire pcWr_i, regWr_i,

    // Status register synchronous control signals
//	input wire clrSlp_i, setPriv_i, flagsWr_i, statWr_i,
    
	// Hidden registers synchornous control signals 
	input wire tempWr_i,

	// General operation control signals
	input wire byteOp_i,

	// Register File operation control signals
	input wire[1:0]	regWrMode_i,
	input wire[2:0] regWrAdr_i, regAdrA_i, regAdrB_i,

	// ALU operand source selection signals 
	input wire aluBRegSel_i, aluBConstSel_i, aluBOffsetSel_i,

	// ALU operation control signals
	input wire[3:0] aluOp_i,
	input wire[3:0] flags_i,
	
    // Status Register operation control & input signals
//	input wire[1:0] statWrMode_i,
//	input wire[2:0] priv_i,
//	input wire[3:0] flagsEn_i,
	
	// PC offset selecion signal
	input wire pcSel_i,
	
	// Address Data source selection Signals
	input wire adrPcSel_i, adrAluSel_i, adrBaseSel_i,

	// Register Write selection signals 
	input wire regAluSel_i, regAddrSel_i, regMemSel_i, regTempSel_i, regPcSel_i, regImmSel_i, 

	// Input data signals
	input wire[15:0] mem_i, branchOffs_i, memOffs_i, immVal_i,

//    output reg slp_o, ie_o,
//    output reg[2:0] prevPriv_o, currPriv_o,
	output reg[3:0] flags_o,
//    output reg[15:0] statOut_o,

	// Memory and Instruction output signals
	output reg[15:0] addr_o, mem_o
);

reg[15:0] 	regWB, pcNew, pcOffset;	// Register File internal data inputs
reg[15:0] 	regA, regB, pc;	// Register file internal data outputs

reg[15:0] 	aluA, aluB;	// ALU internal data inputs
reg[3:0] 	aluFlags, aluByteFlags;	// ALU & Byte ALU internal data outputs
reg[15:0] 	aluOut, aluByteOut, aluRes;

reg[15:0] 	constVal;	// Constant Table internal data output

register_file registerFile (
	.clk_i   (clk_i),
	.arst_i  (arst_i),
	.wrEn_i  (regWr_i),
	.pcEn_i  (pcWr_i),
	.wrMode_i(regWrMode_i),
	.wrAddr_i(regWrAdr_i),
	.rdAddr_i('{regAdrA_i, regAdrB_i}),
	.data_i  (regWB),
	.pc_i    (pcNew),
	.data_o  ('{regA, regB}),
	.pc_o    (pc)
);

ALU alu (
	.cin  (flags_i[0]),
	.op   (aluOp_i),
	.a    (aluA),
	.b    (aluB),
	.flags(aluFlags),
	.res  (aluOut)
);

ALU #(.WORD(8)) byteAlu (
	.cin  (flags_i[0]),
	.op   (aluOp_i),
	.a    (aluA),
	.b    (aluB),
	.flags(aluByteFlags),
	.res  (aluByteOut)
);

// status_register satusRegister (
// 	.clk_i     (clk_i),
// 	.arst_i    (arst_i),
// 	.clrSlp_i  (clrSlp_i),
// 	.setPriv_i (setPriv_i),
// 	.WrEn_i    (statWr_i),
// 	.flagsWr_i (flagsWr_i),
// 	.wrMode_i  (statWrMode_i),
// 	.priv_i    (priv_i),
// 	.data_i    (mem_i),
// 	.flags_i   (statFlagsIn),
// 	.flagsEn_i (flagsEn_i),
// 	.slp_o     (slp_o),
// 	.ie_o      (ie_o),
// 	.prevPriv_o(prevPriv_o),
// 	.currPriv_o(currPriv_o),
// 	.flags_o   (flags_o),
// 	.data_o    (statOut)
// );

PC_offset_select pcOffsetSelect (
	.sel_i   (pcSel_i),
	.branch_i(branchOffs_i),
	.pc_i    (pc),
	.pc_o    (pcNew)
);

constant_table constantTable (
	.addr_i(regAdrB_i),
	.data_o(constVal)
);

reg[WORD-1:0] temp = 0;

always @ (posedge clk_i) begin
    if (tempWr_i) temp <= regB;
end

always @ (*) begin
	// ALU A operand data source selection
	aluA <= regA;

	case (1'b1) 
		aluBRegSel_i:	aluB <= regB;
		aluBConstSel_i:	aluB <= constVal;
		aluBOffsetSel_i:	aluB <= memOffs_i;
		default:		aluB <= 16'hXXXX;
	endcase // ALU B operand data source selection

	// Register Write Back data Selector
	case (1'b1) 
		regAluSel_i:	regWB <= aluRes;
		regAddrSel_i:	regWB <= aluOut;
		regMemSel_i:	regWB <= mem_i;
		regTempSel_i:	regWB <= temp;
		regPcSel_i:		regWB <= pc;
		regImmSel_i:	regWB <= immVal_i;
		default:		regWB <= 16'hXXXX;
	endcase // Register Data Source Selection

	case (1'b1) 
		adrPcSel_i:		addr_o <= pc;
		adrAluSel_i:	addr_o <= aluOut;
		adrBaseSel_i:	addr_o <= aluA;
		default         addr_o <= 16'hXXXX;
	endcase // Address source selection
	
	// if (pswSel_i) begin
	// 	imdrIn <= statOut;
	// 	omdrIn <= statOut;
 //    end
	// else begin
	// 	imdrIn <= mem_i;
	// 	omdrIn <= regB;
	// end

	mem_o <= regB;

	if (byteOp_i) begin
		aluRes 	<= aluByteOut;
		flags_o <= aluByteFlags;
	end
	else begin
		aluRes 	<= aluOut;
		flags_o <= aluFlags;
	end
end

endmodule
