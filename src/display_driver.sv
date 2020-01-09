



module display_driver 
#(
	parameter DISPLAYS = 4
 )
(
	input wire clk_i, en_i,
	input wire[(DISPLAYS*4)-1:0] data_i,

	output reg[DISPLAYS-1:0] dispSel_o,
	output reg[6:0] disp_o
);

localparam NIBBLE = 4;


reg[3:0] dispData[DISPLAYS];

reg[$clog2(DISPLAYS)-1:0] dispCycle;

reg[6:0] dispROM[NIBBLE**2] = {
	7'b0000001,
	7'b1001111,
	7'b0010010,
	7'b0000110,
	7'b1001100,
	7'b0100100,
	7'b0100000,
	7'b0001111,
	7'b0000000,
	7'b0001100,
	7'b0001000,
	7'b1100000,
	7'b0110001,
	7'b1000010,
	7'b0110000,
	7'b0111000
};

initial begin
	dispCycle = 0;
end

always @ (*) begin
	for (int i = 0; i < DISPLAYS; i = i + 1) begin
		dispData[i] <= data_i[i*NIBBLE +: NIBBLE];
	end

	dispSel_o <= 4'b1111;
	
	if (en_i)
	   dispSel_o[dispCycle] <= 0;

	disp_o <= dispROM[dispData[dispCycle]];
end

always @ (posedge clk_i) begin
	if (en_i) 
		dispCycle++;
	else
		dispCycle <= 0;
end

endmodule