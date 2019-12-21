/**
 * @File    X-Makina Memory Module file.
 * @brief   Contains the code for the X-Makina Memory module.
 * @author  Manuel Burnay
 * @date    2019.10.25 (created)
 * @date    2019.10.25 (Last Modified)
 */

/**
 * @brief   Byte Addressable Memory module.
 * @input   clk: Clock signal used to clock memory operations.
 * @input   mem_rd:  Memory read enable control signals.
 * @input   mem_wr:  Memory write enable control signal
 * @input   wr_size: Size of write operation in bytes.
 * @input   wr_addr: Memory write address.
 *                   Uses BYTES parameter to determine its size.
 * @input   rd_addr: Memory read addresses.
 *                   Uses BYTES parameter to determine its size.
 * @input   wr_data: Memory write data word.
 * @output  rd_data: Memory read data words.
 * @param   ACTIVE_EDGE: [0 | 1]
 *                       Allows you to configure the register file to update 
 *                       at either a positive edge of the clock (1),
 *                       or at a negative edge of the clock (0)
 * @param   WORD:        Specifies the size of the memory words in bits.
 * @param   READ_PORTS:  Specifies how many read ports the memory file has.
 * @param   BYTES:       Specifies how many bytes the memory contains.
 * @details The memory reads are synchronous and
 *          need to be enabled via the mem_rd signals.
 *          This Memory module is byte-addressable. 
 *          This comes at a logic and critical path cost to translate
 *          the size of the write operation to individual byte write signals.
 *          The procedure can be easily optimized when knowing the size
 *          of the word, but since it's parameterized the speed/efficiency of this 
 *          module is at the mercy of the synthesizer.
 *          This module has a few elements parameterized 
 *          so it can be used in multiple use-cases.
 *          This has been set-up to be as Verilog compatible as possible, 
 *          but $clog2() SystemVerilog primitive is used 
 *          to compute the write and read addresses.
 */
module memory
#(
    parameter ACTIVE_EDGE = 1,
    parameter WORD = 16,
    parameter READ_PORTS = 2,
    parameter BYTES = 65536
 )
(
    input wire clk, mem_rd[READ_PORTS], mem_wr,
    input wire[(WORD/8)-1:0] wr_size,
    input wire[$clog2(BYTES)-1:0] wr_addr, rd_addr[READ_PORTS],
    input wire[WORD-1:0] wr_data,

    output reg[WORD-1:0] rd_data[READ_PORTS]
);

    localparam BYTE = 8;
    localparam BYTES_IN_WORD = (WORD/BYTE);
    localparam MEM_WORDS = (BYTES/BYTES_IN_WORD);

    reg[WORD-1:0] mem[MEM_WORDS];

    /*
     * Write size/en to write byte enable translation
     * Since it uses both a shift and a subtraction to perform the 
     * Translation, there is a risk of a long critical path
     * if the synthesizer doesn't optimize this operation 
     * based on the WORD parameter
     */
    wire[BYTES_IN_WORD-1:0] wr_byte_en = 
        ((2'b10 << wr_size) - 1) & {BYTES_IN_WORD{mem_wr}};

    integer i, rd_port, wr_byte;

    // Memory contents initialization 
    initial begin
        for (i = 0; i < MEM_WORDS; i = i + 1) begin
           mem[i] <= 0;
       end
    end

    // Write procedure is inside a generate block 
    // so the activation clock edge can be parameterized
    generate
        // Parameter determined memory is updated on a positive edge of clock
        if (ACTIVE_EDGE) begin

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
                 * a for loop is used to address each byte of the memory word.
                 */
                for (wr_byte = 0; wr_byte < BYTES_IN_WORD; wr_byte = wr_byte + 1) 
                begin
                    if (wr_byte_en[wr_byte])    
                        mem[wr_addr][BYTE*wr_byte +: BYTE] <= 
                            wr_data[BYTE*wr_byte +: BYTE]; 
                    /*
                     * This is how you must do bit ranges in verilog
                     * when one of the elements in the range 
                     * calculation isn't constant.
                     * (in this case wr_byte is the non-constant value)
                     */ 
                end
            end
        end
        // Parameter determined memory is updated on a positive edge of clock
        else begin

            // The write procedure is byte addressable, 
            // so a for loop is used to address each byte of the register word.
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
                for (wr_byte = 0; wr_byte < BYTES_IN_WORD; wr_byte = wr_byte + 1) 
                begin
                    if (wr_byte_en[wr_byte])    
                        mem[wr_addr][BYTE*wr_byte +: BYTE] <= 
                            wr_data[BYTE*wr_byte +: BYTE]; 
                    /*
                     * This is how you must do bit ranges in verilog
                     * when one of the elements in the range 
                     * calculation isn't constant.
                     * (in this case wr_byte is the non-constant value)
                     */ 
                end
            end

        end
    endgenerate
    
endmodule : memory