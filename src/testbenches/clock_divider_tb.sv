`timescale 1ns / 1ps

module clock_divider_tb();
    
reg clk_i, clk_o;
    
clock_divider #(.OUTPUT_RATE(1000)) clkDivider (
    .clk_i(clk_i),
    .clk_o(clk_o)
);

initial begin
    clk_i <= 0;
end

always begin
    #5  clk_i <= ~clk_i;
end

endmodule
