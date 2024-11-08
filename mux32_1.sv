`timescale 1ns/10ps
module mux32_1(registerData, d0, d1, d2, d3, d4, readData, mux_n);
	input logic [31:0][63:0] registerData;
	input logic [6:0] mux_n;
	input logic d0, d1, d2, d3, d4;
	output logic readData; //registerData[register][mux_n] ... 0th bit, 1st bit...
	
	logic [3:0][20:0] andBitLogic; //To store the result of AND gates
	logic [3:0] muxbitLogic; // result of 8:1 mux
	logic [3:0] resultingBit; //result after bit selectors. Gets OR'd at the end for ReadData output
	logic d0_Not, d1_Not, d2_Not, d3_Not, d4_Not; // Not gates for MUXs
	
	not #0.05 d0Not(d0_Not, d0);
	not #0.05 d1Not(d1_Not, d1);
	not #0.05 d2Not(d2_Not, d2);
	not #0.05 d3Not(d3_Not, d3);
	not #0.05 d4Not(d4_Not, d4);
	
	//First 8:1 mux
	//first 2:1 mux
	and #0.05 mux2_1_1_1 (andBitLogic[0][0], registerData[0][mux_n], d0_Not);
	and #0.05 mux2_1_1_2 (andBitLogic[0][1], registerData[1][mux_n], d0);
	or #0.05 mux2_1_1_3 (andBitLogic[0][2], andBitLogic[0][0], andBitLogic[0][1]); //
	
	//second 2:1 mux
	and #0.05 mux2_1_2_1 (andBitLogic[0][3], registerData[2][mux_n], d0_Not);
	and #0.05 mux2_1_2_2 (andBitLogic[0][4], registerData[3][mux_n], d0);
	or #0.05 mux2_1_2_3 (andBitLogic[0][5], andBitLogic[0][3], andBitLogic[0][4]); //
	
	//third 2:1 mux
	and #0.05 mux2_1_3_1 (andBitLogic[0][6], registerData[4][mux_n], d0_Not);
	and #0.05 mux2_1_3_2 (andBitLogic[0][7], registerData[5][mux_n], d0);
	or #0.05 mux2_1_3_3 (andBitLogic[0][8], andBitLogic[0][6], andBitLogic[0][7]); //
	
	//fourth 2:1 mux
	and #0.05 mux2_1_4_1 (andBitLogic[0][9], registerData[6][mux_n], d0_Not);
	and #0.05 mux2_1_4_2 (andBitLogic[0][10], registerData[7][mux_n], d0);
	or #0.05 mux2_1_4_3 (andBitLogic[0][11], andBitLogic[0][9], andBitLogic[0][10]); //
	
	//fifth 2:1 mux stage 2
	and #0.05 mux2_1_5_1 (andBitLogic[0][12], andBitLogic[0][2], d1_Not);
	and #0.05 mux2_1_5_2 (andBitLogic[0][13], andBitLogic[0][5], d1);
	or #0.05 mux2_1_5_3 (andBitLogic[0][14], andBitLogic[0][12], andBitLogic[0][13]);
	
	//sixth 2:1 mux stage 2
	and #0.05 mux2_1_6_1 (andBitLogic[0][15], andBitLogic[0][8], d1_Not);
	and #0.05 mux2_1_6_2 (andBitLogic[0][16], andBitLogic[0][11], d1);
	or #0.05 mux2_1_6_3 (andBitLogic[0][17], andBitLogic[0][15], andBitLogic[0][16]);
	
	//seventh 2:1 mux stage 3
	and #0.05 mux2_1_7_1 (andBitLogic[0][18], andBitLogic[0][14], d2_Not);
	and #0.05 mux2_1_7_2 (andBitLogic[0][19], andBitLogic[0][17], d2);
	or #0.05 mux2_1_7_3 (muxbitLogic[0], andBitLogic[0][18], andBitLogic[0][19]);
	
	
	//Second 8:1 mux
	//first 2:1 mux
	and #0.05 mux2_2_1_1 (andBitLogic[1][0], registerData[8][mux_n], d0_Not);
	and #0.05 mux2_2_1_2 (andBitLogic[1][1], registerData[9][mux_n], d0);
	or #0.05 mux2_2_1_3 (andBitLogic[1][2], andBitLogic[1][0], andBitLogic[1][1]); //
	
	//second 2:1 mux
	and #0.05 mux2_2_2_1 (andBitLogic[1][3], registerData[10][mux_n], d0_Not);
	and #0.05 mux2_2_2_2 (andBitLogic[1][4], registerData[11][mux_n], d0);
	or #0.05 mux2_2_2_3 (andBitLogic[1][5], andBitLogic[1][3], andBitLogic[1][4]); //
	
	//third 2:1 mux
	and #0.05 mux2_2_3_1 (andBitLogic[1][6], registerData[12][mux_n], d0_Not);
	and #0.05 mux2_2_3_2 (andBitLogic[1][7], registerData[13][mux_n], d0);
	or #0.05 mux2_2_3_3 (andBitLogic[1][8], andBitLogic[1][6], andBitLogic[1][7]); //
	
	//fourth 2:1 mux
	and #0.05 mux2_2_4_1 (andBitLogic[1][9], registerData[14][mux_n], d0_Not);
	and #0.05 mux2_2_4_2 (andBitLogic[1][10], registerData[15][mux_n], d0);
	or #0.05 mux2_2_4_3 (andBitLogic[1][11], andBitLogic[1][9], andBitLogic[1][10]); //
	
	//fifth 2:1 mux stage 2
	and #0.05 mux2_2_5_1 (andBitLogic[1][12], andBitLogic[1][2], d1_Not);
	and #0.05 mux2_2_5_2 (andBitLogic[1][13], andBitLogic[1][5], d1);
	or #0.05 mux2_2_5_3 (andBitLogic[1][14], andBitLogic[1][12], andBitLogic[1][13]);
	
	//sixth 2:1 mux stage 2
	and #0.05 mux2_2_6_1 (andBitLogic[1][15], andBitLogic[1][8], d1_Not);
	and #0.05 mux2_2_6_2 (andBitLogic[1][16], andBitLogic[1][11], d1);
	or #0.05 mux2_2_6_3 (andBitLogic[1][17], andBitLogic[1][15], andBitLogic[1][16]);
	
	//seventh 2:1 mux stage 3
	and #0.05 mux2_2_7_1 (andBitLogic[1][18], andBitLogic[1][14], d2_Not);
	and #0.05 mux2_2_7_2 (andBitLogic[1][19], andBitLogic[1][17], d2);
	or #0.05 mux2_2_7_3 (muxbitLogic[1], andBitLogic[1][18], andBitLogic[1][19]);
	
	
	//Third 8:1 mux
	//first 2:1 mux
	and #0.05 mux2_3_1_1 (andBitLogic[2][0], registerData[16][mux_n], d0_Not);
	and #0.05 mux2_3_1_2 (andBitLogic[2][1], registerData[17][mux_n], d0);
	or #0.05 mux2_3_1_3 (andBitLogic[2][2], andBitLogic[2][0], andBitLogic[2][1]); //
	
	//second 2:1 mux
	and #0.05 mux2_3_2_1 (andBitLogic[2][3], registerData[18][mux_n], d0_Not);
	and #0.05 mux2_3_2_2 (andBitLogic[2][4], registerData[19][mux_n], d0);
	or #0.05 mux2_3_2_3 (andBitLogic[2][5], andBitLogic[2][3], andBitLogic[2][4]); //
	
	//third 2:1 mux
	and #0.05 mux2_3_3_1 (andBitLogic[2][6], registerData[20][mux_n], d0_Not);
	and #0.05 mux2_3_3_2 (andBitLogic[2][7], registerData[21][mux_n], d0);
	or #0.05 mux2_3_3_3 (andBitLogic[2][8], andBitLogic[2][6], andBitLogic[2][7]); //
	
	//fourth 2:1 mux
	and #0.05 mux2_3_4_1 (andBitLogic[2][9], registerData[22][mux_n], d0_Not);
	and #0.05 mux2_3_4_2 (andBitLogic[2][10], registerData[23][mux_n], d0);
	or #0.05 mux2_3_4_3 (andBitLogic[2][11], andBitLogic[2][9], andBitLogic[2][10]); //
	
	//fifth 2:1 mux stage 2
	and #0.05 mux2_3_5_1 (andBitLogic[2][12], andBitLogic[2][2], d1_Not);
	and #0.05 mux2_3_5_2 (andBitLogic[2][13], andBitLogic[2][5], d1);
	or #0.05 mux2_3_5_3 (andBitLogic[2][14], andBitLogic[2][12], andBitLogic[2][13]);
	
	//sixth 2:1 mux stage 2
	and #0.05 mux2_3_6_1 (andBitLogic[2][15], andBitLogic[2][8], d1_Not);
	and #0.05 mux2_3_6_2 (andBitLogic[2][16], andBitLogic[2][11], d1);
	or #0.05 mux2_3_6_3 (andBitLogic[2][17], andBitLogic[2][15], andBitLogic[2][16]);
	
	//seventh 2:1 mux stage 3
	and #0.05 mux2_3_7_1 (andBitLogic[2][18], andBitLogic[2][14], d2_Not);
	and #0.05 mux2_3_7_2 (andBitLogic[2][19], andBitLogic[2][17], d2);
	or #0.05 mux2_3_7_3 (muxbitLogic[2], andBitLogic[2][18], andBitLogic[2][19]);
	
	
	//Fourth 8:1 mux
	//first 2:1 mux
	and #0.05 mux2_4_1_1 (andBitLogic[3][0], registerData[24][mux_n], d0_Not);
	and #0.05 mux2_4_1_2 (andBitLogic[3][1], registerData[25][mux_n], d0);
	or #0.05 mux2_4_1_3 (andBitLogic[3][2], andBitLogic[3][0], andBitLogic[3][1]); //
	
	//second 2:1 mux
	and #0.05 mux2_4_2_1 (andBitLogic[3][3], registerData[26][mux_n], d0_Not);
	and #0.05 mux2_4_2_2 (andBitLogic[3][4], registerData[27][mux_n], d0);
	or #0.05 mux2_4_2_3 (andBitLogic[3][5], andBitLogic[3][3], andBitLogic[3][4]); //
	
	//third 2:1 mux
	and #0.05 mux2_4_3_1 (andBitLogic[3][6], registerData[28][mux_n], d0_Not);
	and #0.05 mux2_4_3_2 (andBitLogic[3][7], registerData[29][mux_n], d0);
	or #0.05 mux2_4_3_3 (andBitLogic[3][8], andBitLogic[3][6], andBitLogic[3][7]); //
	
	//fourth 2:1 mux
	and #0.05 mux2_4_4_1 (andBitLogic[3][9], registerData[30][mux_n], d0_Not);
	and #0.05 mux2_4_4_2 (andBitLogic[3][10], registerData[31][mux_n], d0);
	or #0.05 mux2_4_4_3 (andBitLogic[3][11], andBitLogic[3][9], andBitLogic[3][10]); //
	
	//fifth 2:1 mux stage 2
	and #0.05 mux2_4_5_1 (andBitLogic[3][12], andBitLogic[3][2], d1_Not);
	and #0.05 mux2_4_5_2 (andBitLogic[3][13], andBitLogic[3][5], d1);
	or #0.05 mux2_4_5_3 (andBitLogic[3][14], andBitLogic[3][12], andBitLogic[3][13]);
	
	//sixth 2:1 mux stage 2
	and #0.05 mux2_4_6_1 (andBitLogic[3][15], andBitLogic[3][8], d1_Not);
	and #0.05 mux2_4_6_2 (andBitLogic[3][16], andBitLogic[3][11], d1);
	or #0.05 mux2_4_6_3 (andBitLogic[3][17], andBitLogic[3][15], andBitLogic[3][16]);
	
	//seventh 2:1 mux stage 3
	and #0.05 mux2_4_7_1 (andBitLogic[3][18], andBitLogic[3][14], d2_Not);
	and #0.05 mux2_4_7_2 (andBitLogic[3][19], andBitLogic[3][17], d2);
	or #0.05 mux2_4_7_3 (muxbitLogic[3], andBitLogic[3][18], andBitLogic[3][19]);
	
	//mux combination
	and #0.05 muxComb1 (resultingBit[0], d3_Not, d4_Not, muxbitLogic[0]);
	and #0.05 muxComb2 (resultingBit[1], d3, d4_Not, muxbitLogic[1]);
	and #0.05 muxComb3 (resultingBit[2], d3_Not, d4, muxbitLogic[2]);
	and #0.05 muxComb4 (resultingBit[3], d3, d4, muxbitLogic[3]);
	or #0.05 outputRead (readData, resultingBit[0], resultingBit[1], resultingBit[2], resultingBit[3]);
	
endmodule 