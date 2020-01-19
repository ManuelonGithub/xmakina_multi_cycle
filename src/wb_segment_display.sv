



module wb_segment_display 
#(
	parameter WORD = 16,
	parameter DISPLAYS = 4
 )
(
	input wire clk_i, rst_i,

	input wire stb_i, cyc_i, we_i,
	input wire[WORD/8-1:0] sel_i,
	input wire[WORD-1:0] dat_i,

	output reg ack_o,
	output reg[WORD-1:0] dat_o,

	output reg[DISPLAYS-1:0] dispSel_o,
	output reg[6:0] disp_o
);

localparam BYTE = 8;
localparam WORD_GL = (WORD/BYTE);    // Word Granularity level (# of bytes in the word)
localparam NIBBLE = 4;

wire en = (stb_i & cyc_i);

reg[WORD-1:0] dispReg;
reg[3:0] dispData[DISPLAYS];

reg[$clog2(DISPLAYS)-1:0] dispCycle;

reg[6:0] dispROM[NIBBLE**2] = {
	7'b1000000,
	7'b1111001,
	7'b0100100,
	7'b0110000,
	7'b0011001,
	7'b0010010,
	7'b0000010,
	7'b1111000,
	7'b0000000,
	7'b0011000,
	7'b0001000,
	7'b0000011,
	7'b1000110,
	7'b0100001,
	7'b0000110,
	7'b0001110
};

initial begin
	dispCycle = 0;
	dispReg = 16'hABCD;
end

always @ (*) begin
	ack_o <= en;
	dat_o <= dispReg;

	for (int i = 0; i < DISPLAYS; i = i + 1) begin
		dispData[i] <= dispReg[i*NIBBLE +: NIBBLE];
	end

	dispSel_o <= 4'b1111;
	dispSel_o[dispCycle] <= 0;

	disp_o <= dispROM[dispData[dispCycle]];
end

always @ (negedge clk_i) begin
    if (rst_i) begin
        dispCycle <= 0;
        dispReg <= 0;
    end
    else begin
        dispCycle++;
        
        if (en & we_i)
            for (int i = 0; i < WORD_GL; i++) begin
                if (sel_i[i])    
                    dispReg[BYTE*i +: BYTE] <= dat_i[BYTE*i +: BYTE];
            end
    end
end
endmodule