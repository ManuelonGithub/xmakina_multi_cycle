



/*
 * Branch logic module.
 * Determines the control logic on
 * whether or not a branch will take place
 * based on the type of branching and the current
 * flag settings in the status register.
 */
module branch_logic_block
(
	input wire[3:0] status, 
	input wire[2:0]	branch_cond,
	output reg 		branch_en
);

	reg[8:0] branch_logic;

    // Ordering of the flags 
	enum {C, Z, N, V} STATUS_bits;

    // All possible branch conditions
    enum {BEQ, BNE, BHS, BLO, BN, BGE, BLT, BAL} BRANCH_TYPES;

    // Branch enable control determination procedure
	always @ (*) begin
        case (branch_cond)
        	BEQ:
        		branch_en <= status[Z];
        	BNE:
        		branch_en <= !status[Z];
        	BHS:
        		branch_en <= status[C];
        	BLO:
        		branch_en <= !status[C];
        	BN:
        		branch_en <= status[N];
        	BGE:
        		branch_en <= ~(status[N] ^ status[V]);
        	BLT:
        		branch_en <= (status[N] ^ status[V]);
        	BAL:
        		branch_en <= 1;
		endcase
	end

endmodule