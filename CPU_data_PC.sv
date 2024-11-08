`timescale 1ns/10ps
module CPU_data_PC #(parameter BITS = 64) (UncondBr, BrTaken, CondAddr19, BRAddr26, instruction, clk, reset);
	input logic UncondBr, BrTaken, clk, reset;
	input logic [18:0] CondAddr19;
   input logic [25:0] BRAddr26;
	output logic [31:0] instruction;
	
	logic [63:0] address, address_add;
	
	logic [31:0] instruction_reg; // Register to use for instructions
	
	logic [63:0] addr_output;
	logic [63:0] resultAdd4, resultAddAddr;
	logic [63:0] CondAddr19_SE, BRAddr26_SE;
	logic [63:0] UncondBr_result1, UncondBr_result2, UncondBr_result3, UncondBr_shift, 
						BrTaken_result1, BrTaken_result2;
	logic UncondBr_Not, BrTaken_Not;
	genvar i, j, k, l, m;
	
	// Clock PC counter on DFF
	generate
		for (k = 0; k < 64; k++) begin : PC
			D_FF PCUpdate(.q(address[k]), .d(addr_output[k]), .clk, .reset);
		end
	endgenerate
	
	//Initialize instructmem module to get the necessary instructions
	instructmem instructions(.address, .instruction(instruction_reg), .clk);
	
	// IF/ID REGISTER
	// send instruction to register
	generate
		for (l = 0; l < 32; l++) begin : instruction_register
			D_FF instructDFF(.q(instruction[l]), .d(instruction_reg[l]), .clk);
		end
	endgenerate
		
	
	not #0.05 UncondBrNot(UncondBr_Not, UncondBr);
	not #0.05 BrTakenNot(BrTaken_Not, BrTaken);
	
	// Sign extend BRAddr26 and CondAddr19 for MUX
	sign_ext #(26) BRAddr26_ext(.input_bus(BRAddr26), .output_bus(BRAddr26_SE), .sign_extension(BRAddr26[25]));
	sign_ext #(19) CondAddr19_ext(.input_bus(CondAddr19), .output_bus(CondAddr19_SE), .sign_extension(CondAddr19[18]));
	
	// Mux between CondAddr19 and BRAddr26 by UncondBr selector
	generate
		for (i = 0; i < BITS; i++) begin : UncondBRMUX
			and #0.05 mux1_1(UncondBr_result1[i], CondAddr19_SE[i], UncondBr_Not);
			and #0.05 mux1_2(UncondBr_result2[i], BRAddr26_SE[i], UncondBr);
			or #0.05 mux1_3(UncondBr_result3[i], UncondBr_result1[i], UncondBr_result2[i]);
		end
	endgenerate
	
	// Shift result to the left by 2 bits
	assign UncondBr_shift[63:0] = {UncondBr_result3[61:0], 2'b00};
	
	// Save PC in register for adder between unconditional branches and address
	generate
		for (m = 0; m < 64; m++) begin : PC_REGISTER_ADDER
			D_FF PCreg(.q(address_add[m]), .d(address[m]), .clk);
		end
	endgenerate
	
	// Add values from +4 adder and UncondAdder
	adder UncondAdder(.A(address_add), .B(UncondBr_shift), .result(resultAddAddr));
	adder Add4(.A(address), .B(64'b100), .result(resultAdd4));
	
	// Generate mux for output
	generate
		for (j = 0; j < 64; j++) begin : BRTakenMUX
			and #0.05 mux2_1(BrTaken_result1[j], resultAdd4[j], BrTaken_Not);
			and #0.05 mux2_2(BrTaken_result2[j], resultAddAddr[j], BrTaken);
			or #0.05 mux2_3(addr_output[j], BrTaken_result1[j], BrTaken_result2[j]);
		end
	endgenerate
	
	
endmodule