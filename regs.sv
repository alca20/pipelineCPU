`timescale 1ns/10ps
module regs #(parameter BITS = 64) (writeEn, WriteData, data, clk);
	input logic writeEn, clk;
	input logic [63:0] WriteData;
	output logic [63:0] data;
	logic [63:0] dataToSend;
	logic [63:0] and1, and2, or1;
	logic writeEn_Not;
	
	not #0.05 writeNot(writeEn_Not, writeEn);
	
	genvar i;
	generate
		for (i = 0; i < BITS; i++) begin : eachMUX
			and #0.05 mux_and_1 (and1[i], data[i], writeEn_Not);
			and #0.05 mux_and_2 (and2[i], WriteData[i], writeEn);
			or #0.05 mux_or (dataToSend[i], and1[i], and2[i]);
			D_FF flipflop(.q(data[i]), .d(dataToSend[i]), .clk(clk));
		end
	endgenerate
	
endmodule