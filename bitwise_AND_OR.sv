`timescale 1ns/10ps

module bitwise_AND_OR #(parameter BITS = 64) (A, B, result, orBit);
	input logic [63:0] A, B;
	input logic orBit;
	output logic [63:0] result;
	
	logic [63:0] AND_result, OR_result, mux_result1, mux_result2;
	logic orBit_NOT;
	
	genvar i, j, k;
	
	not #0.05 orBitNOT(orBit_NOT, orBit);
	
	generate
		// Check the bitwise AND and store in result
		for (i = 0; i < BITS; i++) begin : result_AND
			and #0.05 andBitwise(AND_result[i], A[i], B[i]);
		end
		
		// Check the bitwise OR and store in result
		for (j = 0; j < BITS; j++) begin : result_OR
			or #0.05 andBitwise(OR_result[j], A[j], B[j]);
		end
		
		// To choose whether we use result of OR or AND ops based on cntrl[0] from ALU
		for (k = 0; k < BITS; k++) begin : muxResultPass
			and #0.05 mux1(mux_result1[k], AND_result[k], orBit_NOT);
			and #0.05 mux2(mux_result2[k], OR_result[k], orBit);
			or #0.05 result(result[k], mux_result1[k], mux_result2[k]);
		end
		
		
	endgenerate
endmodule