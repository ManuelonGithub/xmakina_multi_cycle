

module mem_wishbone
#(
    parameter EDGE = 0,
    parameter WORD = 16,
    parameter BYTES = 65536
 )
(
    input wire clk_i, rst_i,
    input wire we_i, stb_i, cyc_i,
    input wire[(WORD/8)-1:0] sel_i,
    input wire[$clog2(BYTES/(WORD/8))-1:0] adr_i,
    input wire[WORD-1:0] dat_i,
    output reg ack_o,
    output reg[WORD-1:0] dat_o
);

    localparam BYTE = 8;
    localparam WORD_GL = (WORD/BYTE);    // Word Granularity level (# of bytes in the word)
    localparam MEM_WORDS = (BYTES/WORD_GL);
    
    wire en = (stb_i & cyc_i);
    wire rd_en = (en & ~we_i);
    wire wr_en = (en & we_i);
    
    reg[WORD-1:0] mem[MEM_WORDS];
    
    integer i, rd_byte, wr_byte;

    // Create module clock based on parametized edge response
    wire clk;
    generate 
        if (EDGE)
            assign clk = clk_i;
        else
            assign clk = ~clk_i; 
    endgenerate

    // Memory contents initialization 
    initial begin
        for (i = 0; i < MEM_WORDS; i = i + 1) begin
           mem[i] <= 0;
       end
    end
    
    always @ (posedge clk) begin
        /*
         * Read Procedure.
         * Due to the parameterized read ports 
         * a for loop is used to address each port.
         */
        for (rd_byte = 0; rd_byte < WORD_GL; rd_byte = rd_byte + 1) begin
            if (sel_i[rd_byte]) 
                dat_o[BYTE*rd_byte +: BYTE] <= mem[adr_i][BYTE*rd_byte +: BYTE]; 
            else                
                dat_o[BYTE*rd_byte +: BYTE] <= 8'hXX;
        end
        /*
         * Write Procedure.
         * Due to memory being byte addressable
         * a for loop is used to address each byte of the memory word.
         */
        if (wr_en) begin
            for (wr_byte = 0; wr_byte < WORD_GL; wr_byte = wr_byte + 1) begin
                if (sel_i[wr_byte])    
                    mem[adr_i][BYTE*wr_byte +: BYTE] <= dat_i[BYTE*wr_byte +: BYTE];
            end
        end 
        /*
         * This is how you must do bit ranges in verilog
         * when one of the elements in the range 
         * calculation isn't constant.
         * (in this case wr_byte is the non-constant value)
         */
         
         if (rst_i | ~en)   ack_o <= 0;
         else               ack_o <= 1;
    end

endmodule
