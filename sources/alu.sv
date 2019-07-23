`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/30/2019 01:57:03 AM
// Design Name: 
// Module Name: ALU
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

module ALU
#(
    parameter DEBUG = 0,
    parameter WORD_SIZE = 16
 )
(
    input wire byte_op,
    input wire[3:0] alu_func,
    
    input wire carry_in,
    input wire[WORD_SIZE-1:0] src_a, src_b,
    
    output reg[3:0] status,
    output reg[WORD_SIZE-1:0] result
);
    enum {C, Z, N, V} STATUS_BITS;

    typedef enum logic[2:0] {ARRITHMETIC = 0, BOOLEAN_LOGIC, SHIFTER, MANIPULATION, BLOCK_COUNT} ALU_BLOCKS;
    
    wire[1:0] block_sel = alu_func[3:2], block_func = alu_func[1:0];

    wire[WORD_SIZE-1:0] block_res[0:BLOCK_COUNT-1];
    wire block_ovf;
    wire block_carry[0:1];
    
    reg block_zero[0:BLOCK_COUNT];
    reg block_neg[0:BLOCK_COUNT];
    
    arrithmetic_block_m arrithmetic_block 
    (
        .src_a(src_a), 
        .src_b(src_b),
        .byte_op(byte_op),
        .sub_op(block_func[1]), 
        .carry_op(block_func[0]), 
        .carry_in(carry_in), 
        .result(block_res[ARRITHMETIC]),
        .carry(block_carry[0]), 
        .ovf(block_ovf)
    );
    
    logic_block_m logic_block
    (
        .src_a(src_a), 
        .src_b(src_b), 
        .func(block_func),
        .result(block_res[BOOLEAN_LOGIC])
    );
    
    shifter_block_m shifter_block
    (
        .src(src_a), 
        .func({byte_op, block_func[0]}),
        .feed_in(carry_in),
        .result(block_res[SHIFTER]),
        .feed_out(block_carry[1])
    );
    
    manipulation_block_m manipulation_block
    (
        .src_a(src_a), 
        .src_b(src_b),
        .func(block_func),
        .result(block_res[MANIPULATION])
    );
    
    generate
    genvar i;
        for (i = 0; i < BLOCK_COUNT; i = i + 1) 
        begin
            always @ (*) 
            begin
                block_zero[i] <= ~|(block_res[i]);
                block_neg[i] <= block_res[i][WORD_SIZE-1];
            end
        end
    endgenerate
    
    always @ (*)
    begin
        result <= block_res[block_sel];
    
        status[C] <= block_carry[(block_sel == SHIFTER)];
        status[Z] <= block_zero[block_sel];
        status[N] <= block_neg[block_sel];
        status[V] <= block_ovf;
    end

    // Simulation debug stuff

    typedef enum logic[3:0] {
        ADD, // Functions pertaining ALU block 0
        ADDC,
        SUB, 
        SUBC,

        XOR, // Functions pertaining ALU block 1
        AND, 
        BIC, 
        BIS, 

        SRA, // Functions pertaining ALU block 2
        RRC,
        NA0, // Only has two functions so need to fill the enum
        NA1, // with N/A's

        MOV, // Functions pertaining ALU block 3
        SWPB, 
        SXT
    } ALU_FUNCTIONS;

    typedef struct packed {
        logic C, Z, N, V;
    } status_t;

    typedef struct packed {
        ALU_FUNCTIONS func;
        ALU_BLOCKS    block;
        status_t      status;
    } alu_debug_t;

    alu_debug_t debug;

    always @ (*) begin
        if (DEBUG) begin
            debug.func <= ALU_FUNCTIONS'(alu_func);
            debug.block <= ALU_BLOCKS'(block_sel);

            debug.status.C <= status[C];
            debug.status.Z <= status[Z];
            debug.status.N <= status[N];
            debug.status.V <= status[V];
        end
        else
            debug <= 0;
    end

endmodule
