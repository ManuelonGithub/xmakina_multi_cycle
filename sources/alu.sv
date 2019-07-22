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

//interface ALU_block_io (input carry_in, byte_op, [1:0] func, [15:0] src_a, [15:0] src_b);
//    logic [15:0] result;
//    logic carry, ovf;
//endinterface

module ALU_m
#(
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
    enum {C, Z, S, V} STATUS_BITS;

    enum {ARRITHMETIC = 0, BOOLEAN_LOGIC, SHIFTER, MANIPULATION, BLOCK_COUNT} BLOCK_SELECTION;
    
    enum {ADD, ADDC,  SUB,   SUBC, ADDB, ADDCB,  SUBB,   SUBCB} ARRITHMETIC_BLOCK_FUNCTIONS;
    enum {XOR, AND,   BIC,   BIS,  XORB, ANDB,   BICB,   BISB}  LOGIC_BLOCK_FUNCTIONS;
    enum {SRA, RRC,                SRAB, RRCB}                  SHIFTER_BLOCK_FUNCTIONS;
    enum {MOV, SWPB,  SXT,         MOVB}                        MANIPULATION_BLOCK_FUNCTIONS;
    
//    ALU_block_io intf[BLOCK_COUNT](.src_a(src_a), .src_b(src_b), .func(block_func), .carry_in(carry_in), .byte_op(byte_op));
    
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
    
//    arrithmetic_block_mi arrithmetic_block(.intf(intf[ARRITHMETIC]));
//    logic_block_mi logic_block(.intf(intf[BOOLEAN_LOGIC]));
//    shifter_block_mi shifter_block(.intf(intf[SHIFTER]));
//    manipulation_block_mi move_block(.intf(intf[MANIPULATION]));
    
//    wire[15:0] block_res[0:BLOCK_COUNT-1] = {
//        intf[ARRITHMETIC].result, 
//        intf[BOOLEAN_LOGIC].result, 
//        intf[SHIFTER].result, 
//        intf[MANIPULATION].result
//    };
    
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
        status[S] <= block_neg[block_sel];
        status[V] <= block_ovf;
    end

endmodule
