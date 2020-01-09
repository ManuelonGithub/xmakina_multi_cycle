



module xm_controller
#(
	parameter WORD = 16,
	parameter LR = 5,
	parameter PC = 7
 )
(
	input wire clk_i, arst_i, debug_i,

	input wire memBusy_i, memWr_i,

	input wire byteOp_i, constSel_i, branchRes_i, bcdEn_i, preAcc_i,
	input wire[1:0] aluWrMode_i, immWrMode_i, memWrMode_i,
	input wire[2:0] regAdrA_i, regAdrB_i,
	input wire[3:0] instOp_i, aluOp_i, flagsEn_i,
	input wire[WORD-1:0] immVal_i, condOffset_i, linkOffset_i,
	input wire[WORD-1:0] accOffset_i, relOffset_i,

    input wire 		dbgMemEn_i,
	input wire[2:0] dbgRegAdr_i,

	output reg pcWr_o, regWr_o, memEn_o, irWr_o, flagsWr_o, tempWr_o,

	output reg byteOp_o, memRW_o, pcSel_o,

	output reg[1:0]	aluBSel_o, adrSel_o,
	output reg[1:0]	regWrMode_o,
	output reg[2:0] regWrSel_o,
	output reg[2:0] regWrAdr_o, regAdrA_o, regAdrB_o,
	
	output reg[3:0] aluOp_o,
	output reg[3:0] flagsEn_o,
	
	output reg[WORD-1:0] branchOffs_o, immVal_o, memOffs_o
);

enum {
	INIT, DEBUG, EXC_CHECK,
	FETCH, DECODE, COND_BRANCH, LINK_BRANCH, 
	ALU, ACC_LOAD, ACC_STORE, REL_LOAD, REL_STORE,
	IMM_LOAD, SWAP, TRAP_CALL, COND_EXEC, 
	BREAK, MEM_CONFIRM, MEM_WRITEBACK, SWAP_2
} STATES;

enum {
	ADD, ADDC, SUB, SUBC, 
	XOR, AND, BIC, BIS, 
	SRA, RRC, RES0, RES1, 
	PASS_B, SWPB, SXT, PASS_A
} ALU_OPS;

enum {PLUS_2, BR_OFFSET} NEW_PC_SEL;
enum {PC_SEL, BASE_ADDR, OFFSET_ADDR, DEBUG_ADDR} ADDR_SEL;
enum {REGB_SEL, CONST_SEL, MEM_OFFS_SEL} ALU_B_SEL;
enum {ALU_WR, PC_WR, MEM_WR, IMM_WR, TEMP_WR, ADDR_WR, DEBUG_WR} REG_WRITE_SEL;

enum {NO_WR, LB_WR, HB_WR, WORD_WR} WRITE_MODES;


reg[4:0] state, next_state;

initial begin
    state 		<= FETCH;
    next_state 	<= FETCH;
end

always @ (*) begin
	pcWr_o 			<= 0;
	regWr_o 		<= 0;
	irWr_o 			<= 0;
	flagsWr_o 		<= 0;
	tempWr_o		<= 0;
	memEn_o 		<= 0;
	memRW_o 		<= 0;
	byteOp_o 		<= 0;
	pcSel_o 		<= PLUS_2;
	adrSel_o		<= PC_SEL;
	regWrSel_o      <= ALU_WR;
	aluBSel_o		<= REGB_SEL;
	regWrMode_o	 	<= aluWrMode_i;
	regWrAdr_o		<= regAdrA_i;
	regAdrA_o		<= regAdrA_i;
	regAdrB_o		<= regAdrB_i;
	aluOp_o         <= ADD;
	flagsEn_o		<= flagsEn_i;
	branchOffs_o    <= linkOffset_i;
	immVal_o		<= immVal_i;
	memOffs_o		<= relOffset_i;

	case (state)
		FETCH: begin
			// Next state is to wait for memory word to arrive & be latched in IR
			// Once it does the decoding circuitry has half an cycle to stabilize
            next_state	<= DECODE;

			memRW_o 	<= 0;		// Set memory access to READ (0)
			pcWr_o 		<= 1;		// Write to PC register
            memEn_o     <= 1;		// Set memory access enable
            adrSel_o	<= PC_SEL;	// Set address source to come from PC
		end

		DECODE: begin
			// Stay in state until memory access is complete
			if (memBusy_i)	next_state <= DECODE;
			else 			next_state <= instOp_i;

			irWr_o <= 1; // Write to instruction register
		end

		COND_BRANCH: begin
			// Execution of conditional branching only requires one cycle
			next_state <= EXC_CHECK;
			
            branchOffs_o 	<= condOffset_i;	// Set branch offset to be the conditional branch offset
			pcSel_o 		<= BR_OFFSET;		// Set the new PC offset to be the branch offset
			if (branchRes_i)	
				pcWr_o 		<= 1;				// Write to PC if branch condition result is true
		end

		LINK_BRANCH: begin
			// Execution of branch with link only requires one cycle
			next_state 	<= EXC_CHECK;
            
            branchOffs_o 	<= linkOffset_i;	// Set branch ofset to be the link branch offset
			pcSel_o 		<= BR_OFFSET;		// Set the new PC offset to be the branch offset
			pcWr_o 			<= 1;				// Write to PC
			regWrAdr_o		<= LR;				// Set the link register as the register address to write to
			regWr_o 		<= 1;				// Write to register file
			regWrMode_o		<= WORD_WR;			// Write full word to register
			regWrSel_o  	<= PC_WR;			// Set register write-back data to be the PC
		end
		
		ALU: begin
			// execution of an ALU instruction only takes one cycle
            next_state 	<= EXC_CHECK;
            
            aluOp_o     <= aluOp_i;		// Set ALU operation to be the decoded operation
            byteOp_o 	<= byteOp_i;	// Set byte-op signal to the decoded byte-op bit
            regWr_o  	<= 1;			// Write to register file
            flagsWr_o 	<= 1;			// Update the flags
            regWrSel_o 	<= ALU_WR;		// Set register write-back data to be the ALU
            regWrMode_o <= aluWrMode_i;	// Set the byte-selection for the register writing to the decoded signal

            if (constSel_i)				// Select the constant table as the ALU operand B source according to the decoded instruction
            	aluBSel_o <= CONST_SEL;
            else	
            	aluBSel_o <= REGB_SEL;
		end

		ACC_LOAD: begin
			// Memory access requires at least an extra cycle in its execution
			next_state 	<= MEM_WRITEBACK;

			memEn_o 		<= 1;	// Enable memory access
			memRW_o 		<= 0;	// Set memory access to be in Read mode

			if (preAcc_i)	// Pick address source depending on the Pre/Post accumulate signal
				adrSel_o	<= OFFSET_ADDR;	// If pre-accumulate is set, then the address comes from addition result
			else
				adrSel_o 	<= BASE_ADDR;	// Else it comes from of the Base address value 

			byteOp_o 		<= byteOp_i;		// Set Byte-op enable bit accordingly
			memOffs_o		<= accOffset_i;		// Set memory offset to be the decoded Accumulate offset
			aluBSel_o 		<= MEM_OFFS_SEL;	// Set the ALU operand B source to be the memory offset

			regAdrA_o 		<= regAdrB_i;	// In a load instruction, the base address comes from register address B
			regWrAdr_o		<= regAdrB_i;	// And so the address write-back also goes to register address B
			regWr_o 		<= 1;			// Enable register write
			regWrSel_o		<= ADDR_WR;		// Set the register write-back data source to be the offsetted address
			regWrMode_o 	<= WORD_WR;		// Full word write-back mode
		end

		ACC_STORE: begin
			// Memory access requires at least an extra cycle in its execution
			next_state <= MEM_CONFIRM;

			memEn_o 		<= 1;	// Enable memory access
			memRW_o 		<= 1;	// Set memory access to be in Write mode

			if (preAcc_i)	// Pick address source depending on the Pre/Post accumulate signal
				adrSel_o	<= OFFSET_ADDR;	// If pre-accumulate is set, then the address comes from addition result
			else
				adrSel_o 	<= BASE_ADDR;	// Else it comes from of the Base address value 

			byteOp_o 		<= byteOp_i;		// Set Byte-op enable bit accordingly
			memOffs_o		<= accOffset_i;		// Set memory offset to be the decoded Accumulate offset
			aluBSel_o 		<= MEM_OFFS_SEL;	// Set the ALU operand B source to be the memory offset
			
			regWr_o 		<= 1;			// Enable register write
			regWrSel_o		<= ADDR_WR;		// Set the register write-back data source to be the offsetted address
			regWrMode_o 	<= WORD_WR;		// Full word write-back mode
		end

		REL_LOAD: begin
			// Memory access requires at least an extra cycle in its execution
			next_state 	<= MEM_WRITEBACK;

			memEn_o 		<= 1;	// Enable memory access
			memRW_o 		<= 0;	// Set memory access to be in Read mode

			byteOp_o 		<= byteOp_i;		// Set the byte-op bit accordingly
			memOffs_o		<= relOffset_i;		// Set memory offset to be the decoded relative offset
			adrSel_o		<= OFFSET_ADDR;		// Set the address source to be the offsetted address
			aluBSel_o 		<= MEM_OFFS_SEL;	// Set ALU operand B to be the memory offset
			regAdrA_o 		<= regAdrB_i;		// In a load instruction, the base address comes from register address B
		end

		REL_STORE: begin
			// Memory access requires at least an extra cycle in its execution
			next_state 	<= MEM_CONFIRM;

			memEn_o 		<= 1;	// Enable memory access
			memRW_o 		<= 1;	// Set memory access to be in Write mode

			byteOp_o 		<= byteOp_i;		// Set the byte-op bit accordingly
			memOffs_o		<= relOffset_i;		// Set memory offset to be the decoded relative offset
			adrSel_o		<= OFFSET_ADDR;		// Set the address source to be the offsetted address
			aluBSel_o 		<= MEM_OFFS_SEL;	// Set ALU operand B to be the memory offset
		end

		IMM_LOAD: begin
			next_state 	<= EXC_CHECK;

			regWr_o  	<= 1;			// Set register write enable
			regWrSel_o  <= IMM_WR;		// Set register write data to be the immediate value
			regWrMode_o <= immWrMode_i;	// Set the register byte write mode to be the decoded value
		end

		SWAP: begin
			next_state <= SWAP_2;

			// Place A into temp
			// Write B to A via ALU
			tempWr_o 	<= 1;	// Enable writing operand A to temporary register

			regWr_o 	<= 1;		// Enable writing to register file
			regWrMode_o	<= WORD_WR;	// Set the register byte write mode so the whole register word is written
			regWrSel_o 	<= ALU_WR;	// Set register write-back data to be the ALU

			aluOp_o		<= PASS_B;	// Set alu operation to pass operand B
		end

		MEM_CONFIRM: begin
			// Remain in this state until the memory access is complete
			if (memBusy_i)
				next_state <= MEM_CONFIRM;
			else
				next_state <= EXC_CHECK;

			byteOp_o <= byteOp_i;
		end

		MEM_WRITEBACK: begin
			// Remain in this state until the memory access is complete
			if (memBusy_i)
				next_state <= MEM_CONFIRM;
			else
				next_state <= EXC_CHECK;

			byteOp_o 	<= byteOp_i;
			regWr_o 	<= 1;			// Enable writing to register file
			regWrSel_o	<= MEM_WR;		// Set register write data source to be from the memory bus
			regWrMode_o	<= memWrMode_i;	// Set register write mode to the decoded memory write mode
		end

		SWAP_2: begin
			next_state <= EXC_CHECK;

			regWrAdr_o 	<= regAdrB_i;	// Set the write-back register to be register B
			regWr_o 	<= 1;			// Enable writing to register file
			regWrMode_o	<= WORD_WR;		// Set the register byte write mode so the whole register word is written
			regWrSel_o 	<= TEMP_WR;		// Set register write-back data to be the Temp. Register
		end

		EXC_CHECK: begin
			if (debug_i) 
				next_state <= DEBUG;
			else
				next_state <= FETCH;
		end

		DEBUG: begin
			if (debug_i) 
				next_state <= DEBUG;
			else
				next_state <= EXC_CHECK;
			
			regAdrA_o	<= dbgRegAdr_i;
			// regWrAdr_o 	<= dbgRegAdr_i;
			// regWr_o 	<= dbgRegWr_i;
			// regWrMode_o	<= WORD_WR;

			memEn_o 	<= dbgMemEn_i;
			adrSel_o 	<= DEBUG_ADDR;
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