`timescale 1ns/10ps

module alu #(parameter BITS = 64) (A, B, cntrl, result, negative, zero, overflow, carry_out);
	input logic [63:0] A, B;
	input logic [2:0] cntrl;
	output logic [63:0] result;
	output logic negative, zero, overflow, carry_out;
	
	// To store the result and to be chosen in the MUX
	logic [63:0] result_add_sub, result_bitAndOr, result_bitXor, 
						resulting_bit1, resulting_bit2, resulting_bit3, resulting_bit4, resulting_bit5;
	logic cntrl2_NOT, cntrl1_NOT;
	
	genvar i;
	
	// To be used later in mux
	not #0.05 cntrl1NOT(cntrl1_NOT, cntrl[1]);
	not #0.05 cntrl2NOT(cntrl2_NOT, cntrl[2]);
	
	// Initialize adder/subtractor module
	adder_subtractor addsubMod(.A(A), .B(B), .sub(cntrl[0]), .result(result_add_sub), 
											.overflow(overflow), .carry_out(carry_out));
	
	// Initialize bitwise AND/OR module
	bitwise_AND_OR andMod(.A(A), .B(B), .result(result_bitAndOr), .orBit(cntrl[0]));
	
	// Initialize bitwise XOR module
	bitwise_XOR xorMod(.A(A), .B(B), .result(result_bitXor));
	
	// MUX to choose which bits to pass, second OR gate result used to activate flags
	generate
		for (i = 0; i < BITS; i++) begin : muxOutputResult
			and #0.05 mux_1(resulting_bit1[i], B[i], cntrl2_NOT, cntrl1_NOT);
			and #0.05 mux_2(resulting_bit2[i], result_add_sub[i], cntrl2_NOT, cntrl[1]);
			and #0.05 mux_3(resulting_bit3[i], result_bitAndOr[i], cntrl[2], cntrl1_NOT);
			and #0.05 mux_4(resulting_bit4[i], result_bitXor[i], cntrl[2], cntrl[1]);
			or #0.05 outputBit(result[i], resulting_bit1[i], resulting_bit2[i], 
									resulting_bit3[i], resulting_bit4[i]);
			or #0.05 flagChecker(resulting_bit5[i], resulting_bit1[i], resulting_bit2[i], 
									resulting_bit3[i], resulting_bit4[i]);
		end
	endgenerate
	
	// Set negative flag
	assign negative = resulting_bit5[63];
	// Set zero flag
	zeroCheck zeroFlag(.result(resulting_bit5), .zero(zero));
	
endmodule