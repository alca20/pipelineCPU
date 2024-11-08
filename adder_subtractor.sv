`timescale 1ns/10ps

module adder_subtractor #(parameter BITS = 64) (A, B, sub, result, overflow, carry_out);
	input logic [63:0] A, B;
	input logic sub;
	output logic [63:0] result;
	output logic overflow, carry_out;
	
	logic [63:0] B_invert, B_toUse, result_mux1, result_mux2, 
						carry_AB, carry_AC, carry_BC;
	logic [64:0] carry_in;
	logic sub_NOT;
	genvar i, j, k, l;
	
	assign carry_in[0] = sub;
	
	//To use for mux
	not #0.05 subNot(sub_NOT, sub);
	
	generate
		// Generate an inverse bus of B input
		for (i = 0; i < BITS; i++) begin : invert
			not #0.05 invert(B_invert[i], B[i]);
		end
		
		// To see whether we use twos complement of B
		for (j = 0; j < BITS; j++) begin : twos_complement
			and #0.05 B_inp(result_mux1[j], B[j], sub_NOT);
			and #0.05 B_inv_inp(result_mux2[j], B_invert[j], sub);
			or #0.05 B_to_use(B_toUse[j], result_mux1[j], result_mux2[j]);
		end
		
		// To calculate the carry out bit
		for (k = 0; k < BITS; k++) begin : carryout
			and #0.05 carryAB(carry_AB[k], A[k], B_toUse[k]);
			and #0.05 carryAC(carry_AC[k], A[k], carry_in[k]);
			and #0.05 carryBC(carry_BC[k], B_toUse[k], carry_in[k]);
			or #0.05 carryOut(carry_in[k+1], carry_AB[k], carry_AC[k], carry_BC[k]);
		end
		
		// Calculate the result of the adder
		for (l = 0; l < BITS; l++) begin : results
			xor #0.05 resultingBit(result[l], carry_in[l], A[l], B_toUse[l]);
		end
	endgenerate 
	// Set overflow flag
	xor #0.05 overflow_flag(overflow, carry_in[64], carry_in[63]);
	// Set carry_out flag
	assign carry_out = carry_in[64];
endmodule 