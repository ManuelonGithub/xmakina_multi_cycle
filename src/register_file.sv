/**
 *  @File
 *      X-Makina Register File Module file.
 *  @brief
 *      Contains the code for the X-Makina Register File.
 *  @author
 *      Manuel Burnay
 *  @date
 *      2019.10.25 (created)
 *  @date
 *      2019.10.25 (Last Modified)
 */

/**
 *  @brief
 *      Register File module.
 *  @param
 *      ACTIVE_EDGE: [0 | 1]
 *      Allows you to configure the register file to update 
 *      at either a positive edge of the clock (1),
 *      or at a negative edge of the clock (0)
 *  @param
 *      WORD: Specifies the size of the register words in bits.
 *  @param
 *      READ_PORTS: Specifies how many read ports the register file has.
 *  @param
 *      REGISTERS: Specifies how many registers the file contains.
 *  @details
 *      The register reads are asynchronous.
 *      This Register File is byte-addressable. 
 *      This should comes at a small logic cost, 
 *      and potentially the worst part is the write signal for every byte in the word.
 *      This module has a few elements parameterized so it can be used in multiple use-cases.
 */
module register_file
#(
    parameter ACTIVE_EDGE = 1,
    parameter WORD = 16,
    parameter READ_PORTS = 2,
    parameter REGISTERS = 8
 )
(
    input wire clk, reset,
    input wire[(WORD/8)-1:0] REG_wr,
    input wire[$clog2(REGISTERS)-1:0] wr_addr, rd_addr[READ_PORTS],
    input wire[WORD-1:0] wr_data,

    output reg[WORD-1:0] rd_data[READ_PORTS]
);

    localparam BYTE = 8;
    localparam BYTES = WORD/BYTE;

    reg[WORD-1:0] R[REGISTERS]; // The registers

    integer i, rd_port, wr_byte;

    initial begin
        for (i = 0; i < REGISTERS; i = i + 1) begin
           R[i] <= 0;
       end
    end

    /*
     * Read procedure.
     * Register File reads are done asynchronously.
     */
    always @ (*) begin
        for (rd_port = 0; rd_port < READ_PORTS; rd_port = rd_port + 1) begin
           rd_data[rd_port] <= R[rd_addr[rd_port]];
       end
    end

    // Write procedure is inside a generate block so the activation clock edge can be parameterized
    generate
        if (ACTIVE_EDGE) begin  // Parameter determined reg file is updated on a positive edge of clock

            /*
             * Write Procedure.
             * Due to memory being byte addressable
             * a for loop is used to address each byte of the register word.
             */
            always @ (posedge(clk)) begin
                for (wr_byte = 0; wr_byte < BYTES; wr_byte = wr_byte + 1) begin
                    if (REG_wr[wr_byte])  R[wr_addr][BYTE*wr_byte +: BYTE] <= wr_data[BYTE*wr_byte +: BYTE];  
                    /*
                     * This is how you must do bit ranges in verilog
                     * when one of the elements in the range calculation isn't constant.
                     * (in this case wr_byte is the non-constant value)
                     */ 
               end
            end

        end
        else begin  // Parameter determined reg file is updated on a negative edge of clock

            /*
             * Write Procedure.
             * Due to memory being byte addressable
             * a for loop is used to address each byte of the register word.
             */
            always @ (negedge(clk)) begin
                for (wr_byte = 0; wr_byte < BYTES; wr_byte = wr_byte + 1) begin
                    if (REG_wr[wr_byte])  R[wr_addr][BYTE*wr_byte +: BYTE] <= wr_data[BYTE*wr_byte +: BYTE];  
                    /*
                     * This is how you must do bit ranges in verilog
                     * when one of the elements in the range calculation isn't constant.
                     * (in this case wr_byte is the non-constant value)
                     */ 
               end
            end

        end
    endgenerate
    
endmodule : register_file