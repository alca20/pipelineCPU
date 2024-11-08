`timescale 1ns/10ps
module decoder(d0, d1, d2, d3, d4, sel, decode);
	input logic d0, d1, d2, d3, d4, sel;
	output logic [31:0] decode;
	logic enable0, enable1, enable2, enable3;
	
	logic d0_Not, d1_Not, d2_Not, d3_Not, d4_Not;
	
	not #0.05 d0Not(d0_Not, d0);
	not #0.05 d1Not(d1_Not, d1);
	not #0.05 d2Not(d2_Not, d2);
	not #0.05 d3Not(d3_Not, d3);
	not #0.05 d4Not(d4_Not, d4);
	
	//Logic for 2:4 decoder
	and #0.05 decode2_4_1 (enable0, d3_Not, d4_Not, sel);
	and #0.05 decode2_4_2 (enable1, d3, d4_Not, sel);
	and #0.05 decode2_4_3 (enable2, d3_Not, d4, sel);
	and #0.05 decode2_4_4 (enable3, d3, d4, sel);
	
	//logic for first 3:8 decoder
	and #0.05 decode3_8_1_1 (decode[0], d0_Not, d1_Not, d2_Not, enable0);
	and #0.05 decode3_8_1_2 (decode[1], d0, d1_Not, d2_Not, enable0);
	and #0.05 decode3_8_1_3 (decode[2], d0_Not, d1, d2_Not, enable0);
	and #0.05 decode3_8_1_4 (decode[3], d0, d1, d2_Not, enable0);
	and #0.05 decode3_8_1_5 (decode[4], d0_Not, d1_Not, d2, enable0);
	and #0.05 decode3_8_1_6 (decode[5], d0, d1_Not, d2, enable0);
	and #0.05 decode3_8_1_7 (decode[6], d0_Not, d1, d2, enable0);
	and #0.05 decode3_8_1_8	(decode[7], d0, d1, d2, enable0);
	
	//logic for second 3:8 decoder
	and #0.05 decode3_8_2_1 (decode[8], d0_Not, d1_Not, d2_Not, enable1);
	and #0.05 decode3_8_2_2 (decode[9], d0, d1_Not, d2_Not, enable1);
	and #0.05 decode3_8_2_3 (decode[10], d0_Not, d1, d2_Not, enable1);
	and #0.05 decode3_8_2_4 (decode[11], d0, d1, d2_Not, enable1);
	and #0.05 decode3_8_2_5 (decode[12], d0_Not, d1_Not, d2, enable1);
	and #0.05 decode3_8_2_6 (decode[13], d0, d1_Not, d2, enable1);
	and #0.05 decode3_8_2_7 (decode[14], d0_Not, d1, d2, enable1);
	and #0.05 decode3_8_2_8 (decode[15], d0, d1, d2, enable1);
	
	//logic for third 3:8 decoder
	and #0.05 decode3_8_3_1 (decode[16], d0_Not, d1_Not, d2_Not, enable2);
	and #0.05 decode3_8_3_2 (decode[17], d0, d1_Not, d2_Not, enable2);
	and #0.05 decode3_8_3_3 (decode[18], d0_Not, d1, d2_Not, enable2);
	and #0.05 decode3_8_3_4 (decode[19], d0, d1, d2_Not, enable2);
	and #0.05 decode3_8_3_5 (decode[20], d0_Not, d1_Not, d2, enable2);
	and #0.05 decode3_8_3_6 (decode[21], d0, d1_Not, d2, enable2);
	and #0.05 decode3_8_3_7 (decode[22], d0_Not, d1, d2, enable2);
	and #0.05 decode3_8_3_8 (decode[23], d0, d1, d2, enable2);
	
	//logic for fourth 3:8 decoder
	and #0.05 decode3_8_4_1 (decode[24], d0_Not, d1_Not, d2_Not, enable3);
	and #0.05 decode3_8_4_2 (decode[25], d0, d1_Not, d2_Not, enable3);
	and #0.05 decode3_8_4_3 (decode[26], d0_Not, d1, d2_Not, enable3);
	and #0.05 decode3_8_4_4 (decode[27], d0, d1, d2_Not, enable3);
	and #0.05 decode3_8_4_5 (decode[28], d0_Not, d1_Not, d2, enable3);
	and #0.05 decode3_8_4_6 (decode[29], d0, d1_Not, d2, enable3);
	and #0.05 decode3_8_4_7 (decode[30], d0_Not, d1, d2, enable3);
	and #0.05 decode3_8_4_8 (decode[31], d0, d1, d2, enable3);
	
endmodule