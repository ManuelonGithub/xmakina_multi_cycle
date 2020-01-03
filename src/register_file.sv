/**
 * @File    X-Makina Register File Module file.
 * @brief   Contains the code for the X-Makina Register File.
 * @author  Manuel Burnay
 * @date    2019.10.25 (created)
 * @date    2019.10.25 (Last Modified)
 */

/**
 * @brief   Byte addressable Register File module.
 * @input   clk:     Clock signal used to clock write operations.
 * @input   reset:   Register File Reset signal.
 * @input   Reg_wr:  Register write control signal. 
 *                   One signal per byte in the word.
 * @input   wr_addr: Register write address. 
 *                   Uses the REGISTERS paramter to determine its size.
 * @input   rd_addr: Register rd_addr addresses.
 *                   Uses the REGISTERS paramter to determine its size.
 * @input   wr_data: Register write data word.
 * @output  rd_data: Register File Read data words.
 * @param   ACTIVE_EDGE: [0 | 1]
 *                       Allows you to configure the register file to update 
 *                       at either a positive edge of the clock (1),
 *                       or at a negative edge of the clock (0)
 * @param   WORD:        Specifies the size of the register words in bits.
 * @param   READ_PORTS:  Specifies how many read ports the register file has.
 * @param   REGISTERS:   Specifies how many registers the file contains.
 *                       Recommended to be a power of 2 to avoid 
 *                       out of scope addression scenarios.
 * @details The register reads are asynchronous.
 *          This Register File is byte-addressable. 
 *          This should comes at a small logic cost, 
 *          and potentially the worst part is the 
 *          write signal for every byte in the word.
 *          This module has a few elements parameterized 
 *          so it can be used in multiple use-cases.
 *          This has been set-up to be as Verilog compatible as possible, 
 *          but $clog2() SystemVerilog primitive is used 
 *          to compute the write and read addresses.
 */
module register_file
#(
    parameter WORD = 16,
    parameter READ_PORTS = 2,
    parameter REGISTERS = 8,
    parameter PC = 7
 )
(
    input wire clk_i, arst_i,

    input wire                          wrEn_i, pcEn_i,
    input wire[(WORD/8)-1:0]            wrMode_i,
    input wire[$clog2(REGISTERS)-1:0]   wrAddr_i, rdAddr_i[READ_PORTS],
    input wire[WORD-1:0]                data_i, pc_i,
    output reg[WORD-1:0]                pc_o, data_o[READ_PORTS]
);

    localparam BYTE = 8;
    localparam BYTES = WORD/BYTE;

    reg[WORD-1:0] R[REGISTERS]; // The registers

    integer i, rd_port, wr_byte;    // Iteration variables

    initial begin
        for (i = 0; i < REGISTERS; i = i + 1) begin
           R[i] <= 0;
       end
    end

    /*
     * Read procedure.
     * Register File reads are done asynchronously.
     * For loop is used so the same code is applicable to 
     * a parameterized amount of read ports.
     */
    always @ (*) begin
        for (rd_port = 0; rd_port < READ_PORTS; rd_port = rd_port + 1) begin
           data_o[rd_port] <= R[rdAddr_i[rd_port]];
       end

       pc_o <= R[PC];
    end

    /*
     * Write Procedure.
     * Due to memory being byte addressable
     * a for loop is used to address each byte of the register word.
     */
    always @ (posedge(clk_i)) begin
        if (wrEn_i) begin
            for (wr_byte = 0; wr_byte < BYTES; wr_byte = wr_byte + 1) begin
                if (wrMode_i[wr_byte])  
                    R[wrAddr_i][BYTE*wr_byte +: BYTE] <= data_i[BYTE*wr_byte +: BYTE];  
                    /*
                     * This is how you must do bit ranges in verilog
                     * when one of the elements in the range 
                     * calculation isn't constant.
                     * (in this case wr_byte is the non-constant value)
                     */ 
            end
        end
        else if (pcEn_i)
            R[PC] <= pc_i;
    end
    
endmodule : register_file