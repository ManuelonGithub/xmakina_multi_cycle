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
	input wire pcWr_i, regWr_i, memEn_i, memWr_i, irWr_i,

	// General operation control signals
	input wire byteOp_i, pcSel_i,

	input wire[1:0] aluBSel_i,

	// Register File operation control signals
	input wire[1:0]	regWrMode_i,
	input wire[2:0] regWrSel_i,
	input wire[2:0] regWrAdr_i, regAdrA_i, regAdrB_i,
    
    input wire[3:0] aluOp_i,
    
	// Input data signals
	input wire[WORD-1:0] mem_i, branchOffs_i,

	output reg badMem_o, pswAddr_o,
	output reg[1:0] datSel_o,
	// Memory and Instruction output signals
	output reg[WORD-(WORD/8):0] mar_o,
	output reg[WORD-1:0] omdr_o, ir_o
);

enum {ALU_WR, PC_WR, MEM_WR, IMM_WR, TEMP_WR} REG_WRITE_SEL;

enum {REGB_SEL, CONST_SEL, MEM_OFFS_SEL} ALU_B_SEL;

reg[WORD-1:0] 	regWB, pcNew, pcOffset;		// Register File internal data inputs
reg[WORD-1:0] 	regA, regB, pc, constVal;	// Register file internal data outputs

reg[WORD-1:0] 	addrSrc;
reg[WORD-(WORD/8):0] addr;

reg[WORD-1:0] aluA, aluB, aluOut;
reg[WORD-1:0] mar, imdr;

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

PC_offset_select pcOffsetSelect (
	.sel_i   (pcSel_i),
	.branch_i(branchOffs_i),
	.pc_i    (pc),
	.pc_o    (pcNew)
);

address_decoder addressDecoder (
	.byteEn_i (byteOp_i),
	.addr_i   (addrSrc),
	.badMem_o (badMem_o),
	.pswAddr_o(pswAddr_o),
	.datSel_o (datSel_o)
);

constant_table constantTable (
	.addr_i(regAdrB_i),
	.data_o(constVal)
);

ALU alu (
    .cin(0), 
    .bcd(0),
    .op(aluOp_i),
    .a(aluA), 
    .b(aluB),
//    .flags(0),
    .res(aluOut)
);

always @ (*) begin
	addrSrc <= pc;

	mar_o <= mar[WORD-1:(WORD/8)-1];
	
	case (regWrSel_i)
	   ALU_WR:     regWB <= aluOut;
	   PC_WR:      regWB <= pc;
	   default:    regWB <= 16'h0000;
	endcase

	aluA <= regA;
	case (aluBSel_i)
		REGB_SEL:	aluB <= regB;
		CONST_SEL:	aluB <= constVal;
		default:	aluB <= 16'h0000;
	endcase
end

always @ (posedge clk_i) begin
	if (memEn_i) begin
		mar 	<= addrSrc;
		omdr_o 	<= regB;
	end

	if (memWr_i) begin
		if (irWr_i)	ir_o 	<= mem_i;
		else		imdr 	<= mem_i;
	end
end

endmodule
