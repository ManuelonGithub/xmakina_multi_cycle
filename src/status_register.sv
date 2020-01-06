



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
    input wire clk_i, arst_i, 

    input wire                      clrSlp_i, setPriv_i, WrEn_i, flagsWr_i,
    input wire[(WORD/8)-1:0]        wrMode_i,
    input wire[FLAGS-1:0]           flags_i, flagsEn_i,
    input wire[$clog2(PLVLS)-1:0]   priv_i,
    input wire[WORD-1:0]            data_i,

    output reg                      slp_o, ie_o,
    output reg[$clog2(PLVLS)-1:0]   prevPriv_o, currPriv_o,
    output reg[FLAGS-1:0]           flags_o,
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
// reg[FLAGS-1:0] flags;
// reg slp, ie;
// reg[PRIVWIDTH-1:0] prevPriv, currPriv;

wire flags_wr = |flagsWr_i;

integer i;

initial begin
    flags_o     <= 0;
    slp_o       <= 0;
    ie_o        <= 0;
    prevPriv_o  <= 0;
    currPriv_o  <= 0;
end

// Register writing procedure 
always @ (posedge clk_i, posedge arst_i) begin
    // Flag bits writing procedure
    if (arst_i) begin
        flags_o     <= 0;
        slp_o       <= 0;
        ie_o        <= 0;
        prevPriv_o  <= 0;
        currPriv_o  <= 0;
    end
    else begin
        if (WrEn_i) begin
            // Register Write Procedure
            if (wrMode_i[0]) begin
                flags_o <= data_i[FLAGS_H:FLAGS_L];
                slp_o   <= data_i[SLP];
                ie_o    <= data_i[IE];
            end
            if (wrMode_i[1]) begin
                currPriv_o <= data_i[CURRP_H:CURRP_L];
                prevPriv_o <= data_i[PREVP_H:PREVP_L];
            end
        end
        else begin
            // Individual Element manipulation/Write procedures
            // Clear Sleep Enable
            if (clrSlp_i)  slp_o <= 0;

            // Flags Write
            if (flagsWr_i) begin
                for (i = 0; i < FLAGS; i++) begin
                    if (flagsEn_i[i])   flags_o[i] <= flags_i[i];
                end
            end

            // Setting Priviledge
            if (setPriv_i) begin
                currPriv_o <= priv_i;
                prevPriv_o <= currPriv_o;
            end
        end
    end
end

// Register output procedure
always @ (*) begin
    data_o <= 0;
    data_o[CURRP_H:CURRP_L] <= currPriv_o;
    data_o[PREVP_H:PREVP_L] <= prevPriv_o;
    data_o[IE]              <= ie_o;
    data_o[SLP]             <= slp_o;
    data_o[FLAGS_H:FLAGS_L] <= flags_o;
end

endmodule