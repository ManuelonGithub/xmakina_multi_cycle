`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/19/2019 08:00:54 PM
// Design Name: 
// Module Name: xmakina_cpu_m
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module xmakina_cpu_m
#(
    parameter DEBUG = 0,
    parameter MEM_DEPTH = 32768
 )
(
    input clk, reset,
    
    input wire rd_done[0:1],
    input wire[15:0] rd_data[0:1],
    
    output reg rd_en[0:1],
    output reg[1:0] wr_en, 
    output reg[14:0] wr_addr, rd_addr[0:1],
    output reg[15:0] wr_data
);

    // Internal inputs to the memory controller
    reg         mem_wr_en, mem_wr_size;
    reg[1:0]    psw_wr = 0;
    reg[15:0]   mem_wr_addr, mem_wr_data;

    reg         mem_rd_en[0:1], mem_rd_size[0:1];
    reg[15:0]   mem_rd_addr[0:1];
    
    // internal outputs from the memory controller
    reg invalid_mem_wr_addr;

    reg         invalid_mem_rd_addr[0:1];
    reg         mem_rd_done[0:1];
    reg[15:0]   mem_rd_data[0:1];

    // Program Counter Control signals 
    reg         pc_fetch_wr, pc_branch_wr;
    reg[1:0]    pc_reg_wr;

    // Program counter inputs
    reg[15:0] pc_reg_in, pc_next_fetch;
    
    // Program Counter Output. (PC_out -> Register File & Fetch Unit)
    reg[15:0] PC_out;

    // Fetch unit control signal
    reg fetch_en;
    
    // Fetch unit output status signals
    reg fetch_err, int_ret, fetch_done;

    // Fetch unit outputs. (addr -> Mem. Controller, data -> Decoder Unit)
    reg[15:0] fetch_data;

    // Decoder unit input
    reg decode_en;
    
    // Decoder unit outputs 
    // Decoded Execution unit 'operands'
    reg      branch_en, new_status_en;
    reg[1:0] reg_wb_mode;
    reg[2:0] branch_cond, macro_op;
    reg[3:0] status_wr_mode;

    // Decoded Instruction operands
    reg[2:0] dst_reg, reg_src_a, reg_src_b;
    reg[15:0] imm_val, addr_offset, branch_offset;

    // Decoded control signals
    reg byte_inst;
    reg[3:0] alu_func;
    reg imm_val_sel, offset_sel, const_sel;
    reg mem_wr, pc_wr;

    // Register File input
    reg[1:0] reg_wr_en;
    reg[15:0] reg_wr_data;

    // Register File outputs
    reg[15:0] reg_out[0:1];

    // Constant Table output 
    reg[15:0] const_out;

    // 
    reg[15:0] alu_src_data;

    // ALU input and output register control signals
    reg operand_in_en, alu_out_en;

    // ALU input and output registers
    reg[15:0] alu_in_a = 0, alu_in_b = 0;
    reg[15:0] alu_out = 0;

    // ALU outputs 
    reg[3:0]  alu_status;
    reg[15:0] alu_result;

    reg       status_update;
    reg[15:0] PSW_out;

    reg[15:0] store_data;

    assign mem_wr_data = store_data;
    assign mem_wr_addr = alu_out;
    assign mem_wr_size = ~byte_inst;
    assign mem_rd_addr[1] = alu_out;
    assign mem_rd_size[1] = ~byte_inst;

    cpu_memory_controller memory_controller (
        .clk            (clk), 
        .reset          (reset), 
        .wr_en          (mem_wr_en), 
        .wr_size        (mem_wr_size), 
        .rd_en          (mem_rd_en), 
        .rd_size        (mem_rd_size), 
        .wr_addr        (mem_wr_addr), 
        .wr_data        (mem_wr_data), 
        .rd_addr        (mem_rd_addr),
        .mem_rd_done    (rd_done),
        .mem_rd_data    (rd_data),
        .mem_rd_en      (rd_en),
        .mem_wr_en      (wr_en), 
        .mem_wr_addr    (wr_addr),
        .mem_rd_addr    (rd_addr),
        .mem_wr_data    (wr_data), 
        .invalid_wr_addr(invalid_mem_wr_addr),
        .invalid_rd_addr(invalid_mem_rd_addr),
        .rd_done        (mem_rd_done),
        .rd_data        (mem_rd_data)
    );
    
    program_counter_unit program_counter (
        .clk      (clk),
        .fetch_en (pc_fetch_wr),
        .branch_en(pc_branch_wr),
        .reg_wr_en(pc_reg_wr),
        .reg_in   (pc_reg_in),
        .branch_offset(branch_offset),
        .PC_out   (PC_out)
    );
    
    instruction_fetch_unit fetch_unit (
        .en             (fetch_en),
        .PC_in          (PC_out),
        .mem_err        (invalid_mem_rd_addr[0]),
        .mem_done       (mem_rd_done[0]),
        .mem_data       (mem_rd_data[0]),
        .mem_en         (mem_rd_en[0]),
        .mem_access_size(mem_rd_size[0]),
        .mem_addr       (mem_rd_addr[0]), 
        .fetch_err      (fetch_err),
        .int_ret        (int_ret),
        .fetch_done     (fetch_done),
        .fetch_data     (fetch_data)
    );
    
    instruction_decoder_unit #(.DEBUG(DEBUG)) decoder_unit (
        .clk           (clk),
        .reset         (reset),
        .en            (decode_en),
        .inst_data     (fetch_data),
        .branch_en     (branch_en),
        .new_status_en (new_status_en),
        .reg_wb_mode   (reg_wb_mode),
        .branch_cond   (branch_cond),
        .macro_op      (macro_op),
        .status_wr_mode(status_wr_mode),
        .dst           (dst_reg),
        .src_a         (reg_src_a),
        .src_b         (reg_src_b),
        .imm_val       (imm_val),
        .addr_offset   (addr_offset),
        .branch_offset (branch_offset),
        .byte_inst     (byte_inst),
        .alu_func      (alu_func),
        .imm_val_sel   (imm_val_sel),
        .offset_sel    (offset_sel),
        .const_sel     (const_sel),
        .mem_wr        (mem_wr),
        .pc_wr         (pc_wr)
    );
    
    control_unit #(.DEBUG(DEBUG)) control_unit (
        .clk          (clk),
        .reset        (reset),
        .fetch_done   (fetch_done),
        .mem_wr_done  (1),
        .mem_rd_done  (mem_rd_done[1]),
        .reg_wb_mode  (reg_wb_mode),
        .branch_en    (branch_en),
        .new_status_en(new_status_en),
        .branch_cond  (branch_cond),
        .macro_op     (macro_op),
        .status_reg   (PSW_out),
        .fetch_en     (fetch_en),
        .pc_fetch_wr  (pc_fetch_wr),
        .pc_branch_wr (pc_branch_wr),
        .decode_en    (decode_en),
        .operand_in_en(operand_in_en),
        .alu_out_en   (alu_out_en),
        .status_wr    (status_update),
        .mem_wr_en    (mem_wr_en),
        .mem_rd_en    (mem_rd_en[1]),
        .reg_wr_en    (reg_wr_en)
    );

    register_file #(.DEBUG(DEBUG)) register_file (
        .clk     (clk),
        .rd_size (~byte_inst),
        .wr_en   (reg_wr_en),
        .wr_addr (dst_reg),
        .rd_addr ({reg_src_a, reg_src_b}),
        .wr_data (reg_wr_data),
        .PC_in   (PC_out),
        .PC_wr_en(pc_reg_wr),
        .rd_data (reg_out),
        .PC_out  (pc_reg_in)
    );

    constant_table constant_table (
        .addr(reg_src_b),
        .data(const_out)
    );

    alu_src_selector src_selector (
        .const_sel  (const_sel),
        .imm_val_sel(imm_val_sel),
        .offset_sel (offset_sel),
        .reg_file_in(reg_out[1]),
        .const_in   (const_out),
        .imm_val_in (imm_val),
        .offset_in  (addr_offset),
        .src_out    (alu_src_data)
    );

    program_status_register #(.DEBUG(DEBUG)) program_status_register (
        .clk           (clk),
        .status_wr     (status_update),
        .wr_en         (0),
        .wr_data       (wr_data),
        .status_in     (alu_status),
        .status_wr_mode(status_wr_mode),
        .PSW_out       (PSW_out)
    );

    ALU #(.DEBUG(DEBUG)) ALU (
        .alu_func(alu_func),
        .carry_in(0),
        .byte_op (byte_inst),
        .src_a   (alu_in_a),
        .src_b   (alu_in_b),
        .status  (alu_status),
        .result  (alu_result)
    );
    
    write_back_selector write_back_selector (
        .mem_wr  (mem_wr),
        .alu_in  (alu_out),
        .mem_in  (mem_rd_data[1]),
        .data_out(reg_wr_data)
    );

    always @ (posedge clk) begin
        if (operand_in_en) begin
            alu_in_a <= reg_out[0];
            alu_in_b <= alu_src_data;
            store_data <= reg_out[1];
        end

        if (alu_out_en)
            alu_out <= alu_result;
    end

endmodule
