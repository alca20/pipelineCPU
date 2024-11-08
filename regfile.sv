`timescale 1ns/10ps
module regfile # (parameter REGS = 31, BITS = 64) (ReadRegister1, ReadRegister2, WriteRegister, WriteData, RegWrite, clk, ReadData1, ReadData2);
	input logic	[4:0] 	ReadRegister1, ReadRegister2, WriteRegister;
	input logic [63:0]	WriteData;
	input logic 			RegWrite, clk;
	output logic [63:0]	ReadData1, ReadData2;
	logic [31:0] decodeWrite, decodeRead1, decodeRead2;
	logic [31:0][63:0] registerData;
	logic [63:0] outputData1, outputData2;

	genvar i, j, k;
	
	decoder writeDecode (.d0(WriteRegister[0]), .d1(WriteRegister[1]), .d2(WriteRegister[2]),
		.d3(WriteRegister[3]), .d4(WriteRegister[4]), .sel(RegWrite), .decode(decodeWrite));
	
	//generate registers 0-30
	generate 
		for (i = 0; i < REGS; i++) begin : eachReg
			regs registers(.writeEn(decodeWrite[i]), .WriteData(WriteData), .data(registerData[i]), .clk(clk));
		end
	endgenerate
	
	//generate register 31
	reg31 register31(.data(registerData[REGS]));
	
	//generate mux for ReadData1 and ReadData2
	generate 
		for (j = 0; j < BITS; j++) begin : mux_64_1_1 	
			mux32_1 readOutput1(.registerData(registerData), .d0(ReadRegister1[0]), .d1(ReadRegister1[1]),
				.d2(ReadRegister1[2]), .d3(ReadRegister1[3]), .d4(ReadRegister1[4]), .readData(ReadData1[j]),
				.mux_n(j));
		end
		
		for (k = 0; k < BITS; k++) begin : mux_64_1_2 
			mux32_1 readOutput1(.registerData(registerData), .d0(ReadRegister2[0]), .d1(ReadRegister2[1]),
				.d2(ReadRegister2[2]), .d3(ReadRegister2[3]), .d4(ReadRegister2[4]), .readData(ReadData2[k]),
				.mux_n(k));
		end
	endgenerate

endmodule