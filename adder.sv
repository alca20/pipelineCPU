`timescale 1ns/10ps
module adder #(parameter BITS = 64) (A, B, result);
	input logic [63:0] A, B;
	output logic [63:0] result;
	logic [63:0] carry_AB, carry_AC, carry_BC;
	logic [64:0] carry_in;
	
	assign carry_in[0] = 1'b0;
	
	genvar k, l;
	
	generate
	
	// To calculate the carry out bit
		for (k = 0; k < BITS; k++) begin : carryout
			and #0.05 carryAB(carry_AB[k], A[k], B[k]);
			and #0.05 carryAC(carry_AC[k], A[k], carry_in[k]);
			and #0.05 carryBC(carry_BC[k], B[k], carry_in[k]);
			or #0.05 carryOut(carry_in[k+1], carry_AB[k], carry_AC[k], carry_BC[k]);
		end
		
		// Calculate the result of the adder
		for (l = 0; l < BITS; l++) begin : results
			xor #0.05 resultingBit(result[l], carry_in[l], A[l], B[l]);
		end
		
	endgenerate 
endmodule 