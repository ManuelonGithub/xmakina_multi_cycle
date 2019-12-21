



/*
 * Status Register module.
 * Supports bit-addressable writing to the flag bits
 * via the flags enable signal (flags_en).
 * It also supports byte-addressable writing.
 */
module status_register
#(
    parameter WORD = 16,
    parameter FLAGS = 4,
    parameter PLVLS = 8
 ) 
(
    input wire clk_i, rst_i, 

    input wire                      clrSlp_i, setPriv,
    input wire[(WORD/8)-1:0]        wrEn_i,
    input wire[$clog2(PLVLS-1):0]   Priv_i,
    input wire[WORD-1:0]            data_i,
    input wire[FLAGS-1:0]           flags_i, wrFlags_i,
    output reg[WORD-1:0]            data_o
);

/*
 * This status register makes slight modifications to the X-Makina ISA.
 * Until it is added into the official documentation, 
 * it should be treated as a proof of concept.
 * 
 * The changes include re-ordering the location of the status bits slightly,
 * and the addition of an interrupt enable signal.
 * 
 * Official status register layout:
 *  15    13 12    8 7      5  4    3    2   1   0
 * |  Prev  |  res  |  Curr  | V | SLP | N | Z | C |
 * 
 * Module's status register layout:
 *  15    13 12    10 9     6  5     4    3    2   1  0
 * |  Curr  |  Prev  |  res  | IE | SLP | V | N | Z | C |
 *
 * At the moment the res field is not writable.
 * The future plan is to use it to store the conditional execution counter.
 */

localparam BYTE = 8;
localparam BYTES = WORD/BYTE;

localparam PRIVWIDTH = $clog2(PLVLS);
localparam RESWIDTH = (WORD - FLAGS - PRIVWIDTH - 2); // (2: 1 for SLP & 1 for IE)

localparam FLAGS_L  = 0;
localparam FLAGS_H  = (FLAGS_L + (FLAGS - 1));
localparam SLP      = FLAGS_H + 1;
localparam IE       = SLP + 1;

localparam CURRP_H  = WORD - 1;
localparam CURRP_L  = (CURRP_H - (PRIVWIDTH - 1));
localparam PREVP_H  = CURRP_L - 1;
localparam PREVP_L  = (PREVP_H - (PRIVWIDTH - 1));

// Individual status registers
reg[FLAGS-1:0] flags;
reg slp, ie;
reg[PRIVWIDTH-1:0] prevPriv, currPriv;

wire flags_wr = |wrFlags_i;

integer i, wr_byte;

initial begin
    flags       <= 0;
    slp         <= 0;
    ie          <= 0;
    prevPriv    <= 0;
    currPriv    <= 0;
end

// Register writing procedure 
always @ (posedge clk_i, posedge rst_i) begin
    // Flag bits writing procedure
    if (rst_i) begin
        flags       <= 0;
        slp         <= 0;
        ie          <= 0;
        prevPriv    <= 0;
        currPriv    <= 0;
    end
    else begin
        if (wrEn_i[0])
            flags <= data_i[FLAGS_H:FLAGS_L];
        else begin	// Selecting between updating flags or updating register bytes
            for (int i = 0; i < FLAGS; i++) begin
                if (wrFlags_i[i]) 	flags[i] <= flags_i[i];
            end
        end

        // Sleep bit writing procedure
        if (wrEn_i[0])      slp <= data_i[SLP];
        else if (clrSlp_i)  slp <= 0;

        // Interrupt Enable writing procedure
        if (wrEn_i[0])      ie <= data_i[IE];

        // Current Priviledge Level writing procedure
        if (wrEn_i[0])      currPriv <= data_i[CURRP_H:CURRP_L];
        else if (setPriv)   currPriv <= Priv_i;

        // Previous Priviledge Level writing procedure
        if (wrEn_i[1])      prevPriv <= data_i[PREVP_H:PREVP_L];
        else if (setPriv)   prevPriv <= currPriv;
    end
end

// Register output procedure
always @ (*) begin
    data_o <= 0;
    data_o[CURRP_H:CURRP_L] <= currPriv;
    data_o[PREVP_H:PREVP_L] <= prevPriv;
    data_o[IE]              <= ie;
    data_o[SLP]             <= slp;
    data_o[FLAGS_H:FLAGS_L] <= flags;
end

endmodule