



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

	output reg pcWr_o, regWr_o, memEn_o, irWr_o,

	output reg byteOp_o,

	output reg[1:0]	regWrMode_o,
	output reg[2:0] regWrAdr_o, regAdrA_o, regAdrB_o,
);

enum {
	FETCH, DECODE, COND_BRANCH, LINK_BRANCH, 
	ALU, ACC_LOAD, ACC_STORE, REL_LOAD, REL_STORE,
	IMM_LOAD, SWAP, TRAP_CALL, COND_EXEC, 
	BREAK, MEM_CONFIRM, MEM_WRITEBACK, SWAP_2, 
	FETCH_WAIT, EXC_CHECK, EXC_ENTRY, EXC_RETURN
} STATES;

reg[4:0] state = FETCH, next_state;

always @ (*) begin
	pcWr_o 			<= 0;
	regWr_o 		<= 0;
	irWr_o 			<= 0;
	memEn_o 		<= 0;
	memRW_o 		<= 1'bX;
	byteOp_o 		<= 0;
	regWrMode_o	 	<= 2'bXX;
	regWrAdr_o		<= regAdrA_i;
	regAdrA_o		<= regAdrA_i;
	regAdrB_o		<= regAdrB_i;
	pcSel_o 		<= 0;

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

		default: begin
			next_state <= FETCH;
		end	
	endcase
end

always @ (negedge clk_i) begin
	state <= next_state;
end

endmodule : xm_controller