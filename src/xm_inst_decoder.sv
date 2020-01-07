/*
 * file: xm_inst_decoder.sv
 * author: Manuel Burnay
 * date created: 2019.12.19
 */

module xm_inst_decoder
#(
	parameter WORD = 16,
	parameter LR = 5,
	parameter PC = 7
 )
(
	input wire[3:0] flags_i,
	input wire[WORD-1:0] inst_i,

	output reg byteOp_o, constSel_o, branchRes_o, bcdEn_o, preAcc_o,
	output reg[1:0]	aluWrMode_o, immWrMode_o, memWrMode_o,
	output reg[2:0] regAdrA_o, regAdrB_o,
	output reg[3:0] aluOp_o, flagsEn_o,
	output reg[4:0] instOp_o,

	output reg[WORD-1:0] immVal_o, condOffset_o, linkOffset_o, 
	output reg[WORD-1:0] accOffset_o, relOffset_o
);


/*****************************************************************************/
/*						Instruction Register alias 						 */
/*****************************************************************************/

wire[WORD-1:0] inst = inst_i;

// always @ (posedge clk_i, posedge arst_i) begin
// 	if (arst_i)		inst <= 0;
// 	else if (en_i)	inst <= inst_i;
// end


/*****************************************************************************/
/*						Instruction Opcode decoding 						 */
/*****************************************************************************/

enum {
	RES_OP0, RES_OP1,
	COND_BRANCH, LINK_BRANCH, 
	ALU,
	ACC_LOAD, ACC_STORE, 
	REL_LOAD, REL_STORE,
	IMM_LOAD,
	SWAP,
	TRAP_CALL,
	COND_EXEC,
	BREAK
} OPERATIONS;

// localparam BL	  	= 16'b000?????????????;
// localparam CB    	= 16'b001?????????????;
// localparam ALU_OP	= 16'b0100????????????;
// localparam ACCLD 	= 16'b010100??????????;
// localparam ACCST 	= 16'b010101??????????;
// localparam TRAP 	= 16'b010110??????????;
// localparam CEX 		= 16'b010111??????????;
// localparam IMOV 	= 16'b011?????????????;
// localparam LDR 		= 16'b10??????????????;
// localparam STR 		= 16'b11??????????????;

// always @ (*) begin
// 	casez(inst)
// 		BL:			instOp_o <= LINK_BRANCH;
// 		CB: 		instOp_o <= COND_BRANCH;
// 		ALU: 		instOp_o <= ALU;
// 		ACCLD: 		instOp_o <= ACC_LOAD;
// 		ACCST: 		instOp_o <= ACC_STORE;
// 		TRAP: 		instOp_o <= TRAP_CALL;
// 		CEX: 		instOp_o <= COND_EXEC;
// 		IMOV: 		instOp_o <= IMM_LOAD;
// 		LDR: 		instOp_o <= REL_LOAD;
// 		STR: 		instOp_o <= REL_STORE;
// 	endcase
// end

always @ (*) begin	
	// Opcode decoding
	// Waterfall-style decoding
	// Should look into ROM-based decoding though.
	// Would make the decoder a lot more re-configurable.
	case (inst[15:14])
		2'b00: begin	// Only Branch instructions fall here
			if (inst[13]) 	instOp_o <= COND_BRANCH;
			else			instOp_o <= LINK_BRANCH;
		end
		2'b01: begin	// A whole whackton of stuff falls here
			case (inst[13:12])
				2'b00: begin	// Swap or ALU instructions fall here
					case (inst[11:8])
						4'b1100: instOp_o <= SWAP;
						default: instOp_o <= ALU;
					endcase // inst[11:8]
				end
				2'b01:begin	// Acc. Load, Acc. Store, SYSTEM CALL or Conditional Execution
					case (inst[11:10])
						2'b00: 	instOp_o <= ACC_LOAD;
						2'b01: 	instOp_o <= ACC_STORE;
						2'b10: 	instOp_o <= TRAP_CALL;
						2'b11: 	instOp_o <= COND_EXEC;
					endcase // inst[12:10]
				end
				2'b10, 2'b11: 	instOp_o <= IMM_LOAD;
			endcase // inst[13:12]
		end
		2'b10: 					instOp_o <= REL_LOAD;
		2'b11: 					instOp_o <= REL_STORE;
	endcase // inst[15:14]
end

/*****************************************************************************/
/*						General Decoding & Definitions						 */
/*****************************************************************************/

localparam BYTE	= 6;
localparam DST_H = 2;
localparam DST_L = 0;
localparam SRC_H = 5;
localparam SRC_L = 3;

enum {NO_WR, LB_WR, HB_WR, WORD_WR} WRITE_MODES;

enum {C, Z, N, V} FLAGS;

assign byteOp_o = inst[BYTE];
assign regAdrA_o = inst[DST_H:DST_L];
assign regAdrB_o = inst[SRC_H:SRC_L];

//always @ (*) begin
//	regAdrA_o <= inst[DST_H:DST_L];
//	regAdrB_o <= inst[SRC_H:SRC_L];
//	byteOp_o  <= inst[BYTE];
//end

/*****************************************************************************/
/*					Immediate Value and Write Mode Decoder					 */
/*****************************************************************************/

wire[1:0] immType = inst[12:11];

localparam IMM_H = 10;
localparam IMM_L = 3;

enum {MOVL, MOVLZ, MOVLS, MOVH} IMM_TYPES;

always @ (*) begin
 	case (immType)
        MOVL: begin
        	immVal_o <= {8'h00, inst[IMM_H:IMM_L]};
        	immWrMode_o <= LB_WR;
        end
        MOVLZ: begin
        	immVal_o <= {8'h00, inst[IMM_H:IMM_L]};
        	immWrMode_o <= WORD_WR;
        end
        MOVLS: begin
			immVal_o <= {8'hFF, inst[IMM_H:IMM_L]};
			immWrMode_o <= WORD_WR;
		end
        MOVH: begin
        	immVal_o <= {inst[IMM_H:IMM_L], 8'h00};
        	immWrMode_o <= HB_WR;
        end
    endcase // inst[12:11]
end

/*****************************************************************************/
/*						Branch offsets & Condition Decoder					 */
/*****************************************************************************/

/* 
 * A branch instruction's last bits (15:13) are
 * 000 for a branch with link
 * 001 for a Conditional branch
 * 
 * Since this decoding section only deals with branch instructions,
 * we only need to account for the differences between 
 * the branching instructions, which in this case it's bit 13. 
 * if 0 then let's assume its a conditional branch,
 * if 1 then let's assume it's a branch with link.
 */

localparam COND_OFFS_H 	= 9;
localparam BL_OFFS_H 	= 12;

localparam COND_SXT = WORD - 1 - COND_OFFS_H - 1;
localparam BL_SXT  	= WORD - 1 - BL_OFFS_H - 1;

localparam COND_H = 12;
localparam COND_L = 10;

enum {BEQ, BNE, BHS, BLO, BN, BGE, BLT, BAL} BRANCH_TYPES;

wire branchType = inst[13];
wire[2:0] cond 	= inst[COND_H:COND_L];

always @ (*) begin
	condOffset_o <= {{COND_SXT{inst[COND_OFFS_H]}}, inst[COND_OFFS_H:0], 1'b0};
	linkOffset_o <= {{BL_SXT{inst[BL_OFFS_H]}}, inst[BL_OFFS_H:0], 1'b0};

    case (cond)
    	BEQ:	branchRes_o <= flags_i[Z];
    	BNE:	branchRes_o <= !flags_i[Z];
    	BHS: 	branchRes_o <= flags_i[C];
    	BLO: 	branchRes_o <= !flags_i[C];
    	BN: 	branchRes_o <= flags_i[N];
    	BGE: 	branchRes_o <= ~(flags_i[N] ^ flags_i[V]);
    	BLT: 	branchRes_o <= (flags_i[N] ^ flags_i[V]);
    	BAL: 	branchRes_o <= 1;
	endcase
end

/*****************************************************************************/
/*						ALU Operation & Write-Mode Decoding					 */
/*****************************************************************************/

localparam ALU_I_H = 11;
localparam ALU_I_L = 7;

localparam ADD_I 	= 5'b0000?;
localparam ADDC_I 	= 5'b0001?;
localparam SUB_I 	= 5'b0010?;
localparam SUBC_I 	= 5'b0011?;
localparam DADD_I 	= 5'b0100?;
localparam CMP_I 	= 5'b0101?;
localparam XOR_I 	= 5'b0110?;
localparam AND_I 	= 5'b0111?;
localparam BIT_I 	= 5'b1000?;
localparam BIC_I 	= 5'b1001?;
localparam BIS_I 	= 5'b1010?;
localparam MOV_I 	= 5'b1011?;
localparam SWAP_I 	= 5'b1100?;
localparam SRA_I 	= 5'b1101?;
localparam RRC_I 	= 5'b1110?;
localparam SWPB_I 	= 5'b11110;
localparam SXT_I	= 5'b11111;

enum {
	ADD, ADDC, SUB, SUBC, 
	XOR, AND, BIC, BIS, 
	SRA, RRC, RES0, RES1, 
	PASS_B, SWPB, SXT, PASS_A
} ALU_OPS;

localparam CONST = 7;

wire[4:0] aluInst = inst[ALU_I_H:ALU_I_L];

always @ (*) begin
	// V = 0, N = 1, Z = 1, C = 0
	flagsEn_o <= 4'b0110;

	// Always write low byte, high byte only if byte bit is 0
	aluWrMode_o <= {~byteOp_o, 1'b1};	
	bcdEn_o <= 1'b0;
	constSel_o <= inst[CONST];

	casez(aluInst)
		ADD_I: begin
			aluOp_o <= ADD;
			flagsEn_o <= 4'b1111;
		end
		ADDC_I: begin
			aluOp_o <= ADDC;
			flagsEn_o <= 4'b1111;
		end
		SUB_I: begin
			aluOp_o <= SUB;
			flagsEn_o <= 4'b1111;
		end
		SUBC_I: begin
			aluOp_o <= SUBC;
			flagsEn_o <= 4'b1111;
		end
		DADD_I: begin
			aluOp_o <= ADD;
			bcdEn_o <= 1'b1;
			flagsEn_o <= 4'b1111;
		end
		CMP_I: begin
			aluOp_o <= SUB;
			aluWrMode_o <= NO_WR;
			flagsEn_o <= 4'b1111;
		end
		XOR_I: begin
			aluOp_o <= XOR;
		end
		AND_I: begin
			aluOp_o <= AND;
		end
		BIT_I: begin
			aluOp_o <= AND;
			aluWrMode_o <= NO_WR;
		end
		BIC_I: begin
			aluOp_o <= BIC;
		end
		BIS_I: begin
			aluOp_o <= BIS;
		end
		MOV_I, SWAP_I: begin
			aluOp_o <= PASS_B;
			flagsEn_o <= 4'b0000;
		end
		SRA_I: begin
			aluOp_o <= SRA;
			flagsEn_o[C] <= 1'b1;
		end
		RRC_I: begin
			aluOp_o <= RRC;
			flagsEn_o[C] <= 1'b1;
		end
		SWPB_I: begin
			flagsEn_o <= 0;
			aluOp_o <= SWPB;
		end
		SXT_I: begin
			flagsEn_o <= 0;
			aluOp_o <= SXT;
		end
	endcase
end

/*****************************************************************************/
/*						Memory Offset & Write-mode Decoding					 */
/*****************************************************************************/

localparam MEM_OFFS_H = 13;
localparam MEM_OFFS_L = 7;

localparam MEM_SXT = WORD - 1 - (MEM_OFFS_H - MEM_OFFS_L);

localparam ACC_H = 8;
localparam ACC_L = 6;

localparam PRPO  = 9;

localparam NO_INC 	= 3'b00?;
localparam INC_2 	= 3'b010;
localparam INC_1 	= 3'b011;
localparam DEC_2 	= 3'b100;
localparam DEC_1 	= 3'b101;
localparam INVALID	= 3'b11?;

wire[2:0] accMode = inst[ACC_H:ACC_L];

always @ (*) begin
	relOffset_o <= {{MEM_SXT{inst[MEM_OFFS_H]}},inst[MEM_OFFS_H:MEM_OFFS_L]};
	memWrMode_o <= {~byteOp_o, 1'b1};
	preAcc_o 	<= inst[PRPO];

	casez(accMode)
		NO_INC:		accOffset_o <= 16'h0;
		INC_2:		accOffset_o <= 16'h2;
		INC_1:		accOffset_o <= 16'h1;
		DEC_2:		accOffset_o <= -16'h2;
		DEC_1:		accOffset_o <= -16'h1;
		INVALID:	accOffset_o <= 0;
	endcase
end	

endmodule


