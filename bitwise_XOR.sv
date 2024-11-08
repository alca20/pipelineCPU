`timescale 1ns/10ps

module bitwise_XOR #(parameter BITS = 64) (A, B, result);
	input logic [63:0] A, B;
	output logic [63:0] result;
	
	genvar i;
	
	generate
		// Check the bitwise XOR and store in result
		for (i = 0; i < BITS; i++) begin : result_XOR
			xor #0.05 xorBitwise(result[i], A[i], B[i]);
		end
	endgenerate
endmodule 