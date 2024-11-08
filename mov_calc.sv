`timescale 1ns/10ps
module mov_calc (Rd_data, imm16, shamt, mov_type, mov_output);
	input logic [63:0] Rd_data;
	input logic [15:0] imm16;
	input logic [1:0] shamt;
	input logic mov_type; // 0 - movk, 1 - movz
	output logic [63:0] mov_output;
	
	logic [63:0] movz_shift0, movz_shift1, movz_shift2, movz_shift3, 
					   movk_shift0, movk_shift1, movk_shift2, movk_shift3;
	logic [63:0] movz_output, movk_output, movz0_res, movz1_res, movz2_res, movz3_res, movk0_res, 
						movk1_res, movk2_res, movk3_res, mux1_res, mux2_res;
	logic mov_type_Not, shamt0, shamt1, shamt0_Not, shamt1_Not;
	
	genvar i, j, k;
	
	not #0.05 movNot(mov_type_Not, mov_type);
	
	
	// Concatonate possible shift results
	assign movz_shift0 = {48'b0, imm16[15:0]};
	assign movz_shift1 = {32'b0, imm16[15:0], 16'b0};
	assign movz_shift2 = {16'b0, imm16[15:0], 32'b0};
	assign movz_shift3 = {imm16[15:0], 48'b0};
	
	assign movk_shift0 = {Rd_data[63:16], imm16[15:0]};
	assign movk_shift1 = {Rd_data[63:32], imm16[15:0], Rd_data[15:0]};
	assign movk_shift2 = {Rd_data[63:48], imm16[15:0], Rd_data[31:0]};
	assign movk_shift3 = {imm16[15:0], Rd_data[47:0]};
	
	// set up logic for selector bits based on shamt
	assign shamt0 = shamt[0];
	assign shamt1 = shamt[1];
	
	not #0.05 shamt0Not(shamt0_Not, shamt0);
	not #0.05 shamt1Not(shamt1_Not, shamt1);

	// generate muxs
	generate
		for (j = 0; j < 64; j++) begin : MOVZ_MUX
			and #0.05 mux1_1(movz0_res[j], movz_shift0[j], shamt0_Not, shamt1_Not);
			and #0.05 mux1_2(movz1_res[j], movz_shift1[j], shamt0, shamt1_Not);
			and #0.05 mux1_3(movz2_res[j], movz_shift2[j], shamt0_Not, shamt1);
			and #0.05 mux1_4(movz3_res[j], movz_shift3[j], shamt0, shamt1);
			or #0.05 mux1_5(movz_output[j], movz0_res[j], movz1_res[j], movz2_res[j], movz3_res[j]);
		end
		
		for (k = 0; k < 64; k++) begin : MOVK_MUX
			and #0.05 mux2_1(movk0_res[k], movk_shift0[k], shamt0_Not, shamt1_Not);
			and #0.05 mux2_2(movk1_res[k], movk_shift1[k], shamt0, shamt1_Not);
			and #0.05 mux2_3(movk2_res[k], movk_shift2[k], shamt0_Not, shamt1);
			and #0.05 mux2_4(movk3_res[k], movk_shift3[k], shamt0, shamt1);
			or #0.05 mux2_5(movk_output[k], movk0_res[k], movk1_res[k], movk2_res[k], movk3_res[k]);
		end
		
		
		for (i = 0; i < 64; i++) begin : MOV_MUX
			and #0.05 mux1(mux1_res[i], movk_output[i], mov_type_Not);
			and #0.05 mux2(mux2_res[i], movz_output[i], mov_type);
			or #0.05 mux3(mov_output[i], mux1_res[i], mux2_res[i]);
		end
	endgenerate
	
	
endmodule