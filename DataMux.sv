`timescale 1ns/10ps
module DataMux (current_reg_data, data_out, WriteData, sel0, sel1, ReadData_res);
	input logic [63:0] current_reg_data, data_out, WriteData;
	input logic sel0, sel1;
	output logic [63:0] ReadData_res;
	
	logic [63:0] and_res1, and_res2, and_res3, and_res4, forward_data;
	logic sel0_Not, sel1_Not;
	
	not #0.05 notSel0(sel0_Not, sel0);
	not #0.05 notSel1(sel1_Not, sel1);
	
	genvar i, j;
	
	generate
		for (i = 0; i < 64; i++) begin : ALU_WRITEDATA_MUX
			and #0.05 (and_res1[i], WriteData[i], sel0);
			and #0.05 (and_res2[i], data_out[i], sel0_Not);
			or (forward_data[i], and_res1[i], and_res2[i]);
		end
		
		for (j = 0; j < 64; j++) begin : FORWARD_CURRDATA_MUX
			and #0.05 (and_res3[j], forward_data[j], sel1);
			and #0.05 (and_res4[j], current_reg_data[j], sel1_Not);
			or #0.05 (ReadData_res[j], and_res3[j], and_res4[j]);
		end
	endgenerate
endmodule