`timescale 1ns/10ps
module sign_ext #(parameter CURRBITS = 26) (input_bus, output_bus, sign_extension);
	input logic [CURRBITS-1: 0] input_bus;
	input logic sign_extension;
	output logic [63:0] output_bus;
	
	genvar i;
	
	// Sign extend the output with the bit specified by sign_extension
	generate
		for (i = CURRBITS; i < 64; i++) begin : Extension
			or #0.05 signExtend(output_bus[i], 1'b0, sign_extension);
		end
	endgenerate
	
	// Connect the output bus with the input bus bits
	assign output_bus[CURRBITS-1:0] = input_bus[CURRBITS-1:0];
			
endmodule