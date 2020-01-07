`timescale 1ns / 1ps


module cpu_tb();

reg clk, rst;

reg memAck, we, stb, cyc;
reg[1:0] sel;
reg[14:0] adr;
reg[15:0] memDat, cpuDat;

xm_cpu cpu (
    .clk_i(clk),
    .arst_i(rst),
    .ack_i(memAck),
    .dat_i(memDat),
    .we_o(we), 
    .stb_o(stb), 
    .cyc_o(cyc),
    .sel_o(sel),
    .adr_o(adr),
    .dat_o(cpuDat)
);

mem_wishbone #(.INIT_FILE("mem_access_test.mem")) mem (
    .clk_i(clk), 
    .rst_i(rst),
    .we_i(we), 
    .stb_i(stb), 
    .cyc_i(cyc),
    .sel_i(sel),
    .adr_i(adr),
    .dat_i(cpuDat),
    .ack_o(memAck),
    .dat_o(memDat)
);

initial begin
    clk <= 0;
    rst <= 0;
end

always begin
    #5 clk <= ~clk;
end


endmodule
