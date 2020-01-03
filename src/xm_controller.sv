



module xm_controller
#(
	parameter WORD = 16,
	parameter LR = 5,
	parameter PC = 7
 )
(
	input wire clk_i, arst_i,

	input wire memBusy_i,

	// input wire[3:0] flags_i,
	// input wire[WORD-1:0] inst_i,

	input wire byteOp_i, constSel_i, branchRes_i, bcdEn_i,
	input wire[1:0] aluWrMode_i, immWrMode_i, memWrMode_i,
	input wire[2:0] regAdrA_i, regAdrB_i,
	input wire[3:0] instOp_i, aluOp_i, flagsEn_i,
	input wire[WORD-1:0] immVal_i, condOffset_i, jumpOffset_i,
	input wire[WORD-1:0] accOffset_i, relOffset_i,

	// Register file synchrnous control signals
	output reg pcWr_o, regWr_o,

	// Status register synchronous control signals
	output reg clrSlp_o, setPriv_o, flagsWr_o, statWr_o,

	output reg decEn_o, tempWr_o, 

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

	// reg byteOp, constSel, branchRes, bcdEn;
	// reg[1:0] aluWrMode, immWrMode, memWrMode;
	// reg[2:0] regAdrA, regAdrB;
	// reg[3:0] instOp, aluOp, flagsEn;

	// reg[WORD-1:0] immVal, condOffset, jumpOffset;
	// reg[WORD-1:0] accOffset, relOffset;

enum {
	FETCH, DECODE, COND_BRANCH, LINK_BRANCH, 
	ALU, ACC_LOAD, ACC_STORE, REL_LOAD, REL_STORE,
	IMM_LOAD, SWAP, TRAP_CALL, COND_EXEC, 
	BREAK, MEM_CONFIRM, MEM_WRITEBACK, SWAP_2, 
	FETCH_WAIT, EXC_CHECK, EXC_ENTRY, EXC_RETURN
} STATES;

reg[4:0] state = FETCH, next_state;

reg[2:0] addrSel;
assign adrPcSel_o 	= addrSel[0];
assign adrAluSel_o 	= addrSel[1];
assign adrBaseSel_o = addrSel[2];

reg[5:0] regSel;
assign regAluSel_o 	= regSel[0];
assign regAddrSel_o = regSel[1];
assign regMemSel_o 	= regSel[2];
assign regTempSel_o = regSel[3];
assign regPcSel_o 	= regSel[4];
assign regImmSel_o 	= regSel[5];

always @ (*) begin
	pcWr_o 			<= 0;
	regWr_o 		<= 0;
	clrSlp_o 		<= 0;
	setPriv_o 		<= 0;
	flagsWr_o		<= 0;
	statWr_o 		<= 0;
	decEn_o 			<= 0;
	tempWr_o 		<= 0;
	memEn_o 		<= 0;
	memRW_o 		<= 1'bX;
	byteOp_o 		<= 0;
	regWrMode_o	 	<= 2'bXX;
	regWrAdr_o		<= regAdrA_i;
	regAdrA_o		<= regAdrA_i;
	regAdrB_o		<= regAdrB_i;
	aluBRegSel_o	<= 0;
	aluBConstSel_o	<= 0;
	aluBOffsetSel_o	<= 0;
	aluOp_o			<= 4'hX;
	flagsEn_o		<= flagsEn_i;	// Decoded signal \goes directly here
	adrPcSel_o		<= 0;
	adrAluSel_o		<= 0;
	adrBaseSel_o	<= 0;
	pcSel_o 		<= 0;
	regAluSel_o		<= 0;
	regAddrSel_o 	<= 0;
	regMemSel_o		<= 0;
	regTempSel_o	<= 0;
	regPcSel_o		<= 0;
	regImmSel_o		<= 0;
	branchOffs_o 	<= 0;	
	memOffs_o		<= 0;
	immVal_o		<= immVal_i;	// Decoded signal goes directly here

	case (state)
		FETCH: begin
			if (memBusy_i) begin
				next_state <= FETCH_WAIT;
			end
			else begin
				next_state	<= DECODE;
				pcWr_o 		<= 1;
				memEn_o 	<= 1;
			end

			adrPcSel_o	<= 1;
			memRW_o 	<= 0;
		end

		DECODE: begin
			if (memBusy_i)	next_state <= DECODE;
			else 			next_state <= instOp_i;

			decEn_o <= 1;
		end

		COND_BRANCH: begin
			next_state <= FETCH;

			pcSel_o <= 1;
			if (branchRes_i)	pcWr_o <= 1;
		end

		LINK_BRANCH: begin
			next_state 	<= FETCH;

			pcSel_o 	<= 1;
			pcWr_o 		<= 1;

			regWrAdr_o	<= LR;
			regPcSel_o 	<= 1;
			regWr_o 	<= 1;
			regWrMode_o	<= 2'b11;
		end

		ALU: begin
		    next_state <= FETCH;
		
			regWr_o 	<= 1;
			flagsWr_o 	<= 1;
			aluOp_o 	<= aluOp_o;
			regWrMode_o	<= aluWrMode_i;
		end

		default: begin
			next_state <= FETCH;
		end	
	endcase
end

always @ (negedge clk_i) begin
	state <= next_state;
end

endmodule : xm_controller