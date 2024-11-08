`timescale 1ns/10ps
module ALUSrcMUX #(parameter BITS = 64) (ReadData2, DAddr9_EXT, imm12_EXT, ALUSrc1, ALUSrc2, ALUData2);
	input logic [63:0] ReadData2, DAddr9_EXT, imm12_EXT;
	input logic ALUSrc1, ALUSrc2;
	output logic [63:0] ALUData2;
	
	logic [63:0] data_result1, data_result2, data_result3, data_result4, data_result5;
	logic ALUSrc1_Not, ALUSrc2_Not;
	
	genvar i, j;
	
	not #0.05 ALUSrc1Not(ALUSrc1_Not, ALUSrc1);
	not #0.05 ALUSrc2Not(ALUSrc2_Not, ALUSrc2);
	
	// To choose between imm12, DAddr9, and ReadData2 for ALU
	// 00: ReadData2, 01: DAdd9, 10: imm12
	generate
		for (i = 0; i < BITS; i++) begin : ReadData2_DAddr9_MUX
			and #0.05 mux1_1(data_result1[i], ReadData2[i], ALUSrc1_Not);
			and #0.05 mux1_2(data_result2[i], DAddr9_EXT[i], ALUSrc1);
			or #0.05 mux1_3(data_result3[i], data_result1[i], data_result2[i]);
		end
		
		for (j = 0; j < BITS; j++) begin : MUX1_imm12_MUX
			and #0.05 mux2_1(data_result4[j], data_result3[j], ALUSrc2_Not);
			and #0.05 mux2_2(data_result5[j], imm12_EXT[j], ALUSrc2);
			or #0.05 mux2_3(ALUData2[j], data_result4[j], data_result5[j]);
		end
	endgenerate
endmodule 