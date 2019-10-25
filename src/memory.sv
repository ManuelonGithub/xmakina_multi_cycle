/**
 *  @File
 *      X-Makina Memory Module file.
 *  @brief
 *      Contains the code for the X-Makina Memory module.
 *  @author
 *      Manuel Burnay
 *  @date
 *      2019.10.25 (created)
 *  @date
 *      2019.10.25 (Last Modified)
 */

module memory
#(
    parameter ACTIVE_EDGE = 1,
    parameter WORD = 16,
    parameter READ_PORTS = 2,
    parameter BYTES = (1 << 16)
 )
(
    input wire clk, mem_rd[READ_PORTS],
    input wire[(WORD/8)-1:0] mem_wr,
    input wire[$clog2(BYTES)-1:0] wr_addr, rd_addr[READ_PORTS],
    input wire[WORD-1:0] wr_data,

    output reg[WORD-1:0] rd_data[READ_PORTS]
);

    localparam BYTE = 8;
    localparam BYTES_IN_WORD = (WORD/BYTE);
    localparam MEM_WORDS = (BYTES/BYTES_IN_WORD);

    reg[WORD-1:0] mem[MEM_WORDS];

    integer i, rd_port, wr_byte;

    initial begin
        for (i = 0; i < MEM_WORDS; i = i + 1) begin
           mem[i] <= 0;
       end
    end

    // Memory procedure is inside a generate block so the activation clock edge can be parameterized
    generate
        if (ACTIVE_EDGE) begin  // Parameter determined memory is updated on a positive edge of clock

            always @ (posedge(clk)) begin

                /*
                 * Read Procedure.
                 * Due to the parameterized read ports 
                 * a for loop is used to address each port.
                 */
                for (rd_port = 0; rd_port < READ_PORTS; rd_port = rd_port + 1) begin
                   if (mem_rd[rd_port]) rd_data[rd_port] <= mem[rd_addr[rd_port]];
                end

                /*
                 * Write Procedure.
                 * Due to memory being byte addressable
                 * a for loop is used to address each byte of the register word.
                 */
                for (wr_byte = 0; wr_byte < BYTES_IN_WORD; wr_byte = wr_byte + 1) begin
                    if (mem_wr[wr_byte])    mem[wr_addr][BYTE*wr_byte +: BYTE] <= wr_data[BYTE*wr_byte +: BYTE]; 
                    /*
                     * This is how you must do bit ranges in verilog
                     * when one of the elements in the range calculation isn't constant.
                     * (in this case wr_byte is the non-constant value)
                     */ 
                end
            end
        end
        else begin  // Parameter determined memory is updated on a positive edge of clock

            // The write procedure is byte addressable, so a for loop is used to address each byte of the register word.
            always @ (negedge(clk)) begin

                /*
                 * Read Procedure.
                 * Due to the parameterized read ports 
                 * a for loop is used to address each port.
                 */
                for (rd_port = 0; rd_port < READ_PORTS; rd_port = rd_port + 1) begin
                   if (mem_rd[rd_port]) rd_data[rd_port] <= mem[rd_addr[rd_port]];
                end

                /*
                 * Write Procedure.
                 * Due to memory being byte addressable
                 * a for loop is used to address each byte of the register word.
                 */
                for (wr_byte = 0; wr_byte < BYTES_IN_WORD; wr_byte = wr_byte + 1) begin
                    if (mem_wr[wr_byte])    mem[wr_addr][BYTE*wr_byte +: BYTE] <= wr_data[BYTE*wr_byte +: BYTE]; 
                    /*
                     * This is how you must do bit ranges in verilog
                     * when one of the elements in the range calculation isn't constant.
                     * (in this case wr_byte is the non-constant value)
                     */ 
                end
            end

        end
    endgenerate
    
endmodule : memory