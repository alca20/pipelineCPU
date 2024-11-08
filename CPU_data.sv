// NOTE: Each control signal/Rd register is defined by a number, which represent which register it comes from.
// IF/ID - Rd
// ID/EX - Rd_1
// EX/MEM - Rd_2
// MEM/WR - Rd_3


`timescale 1ns/10ps
module CPU_data (Rd, Rm, Rn, DAddr9, imm12, imm16, Reg2Loc, ALUSrc, ALU_Op, MemToReg, mem_writeEn,
						reg_writeEn, set_flags, curr_negative, curr_zero, curr_overflow, curr_carryout, ReadData2_zero, mem_xfer, mem_byte,
						im_shamt, mov_type, mov_Op, address_CBZ, clk);
	input logic [63:0] address_CBZ;
	input logic [4:0] Rd, Rm, Rn;
	input logic [15:0] imm16;
	input logic [11:0] imm12;
	input logic [8:0] DAddr9;
	input logic Reg2Loc, MemToReg, mem_writeEn, reg_writeEn;
	input logic [2:0] ALU_Op;
	input logic [3:0] mem_xfer;
	input logic [1:0] ALUSrc;
	input logic [1:0] im_shamt;
	input logic set_flags, mov_type, mov_Op, mem_byte;
	input logic clk;
	output logic curr_negative, curr_zero, curr_overflow, curr_carryout, ReadData2_zero;
	
	logic [63:0] ReadData1, ReadData2, WriteData;
	logic [63:0] DAddr9_EXT, imm12_EXT;
	logic [63:0] ALUData2; // second input of ALU
	logic [63:0] ALU_result;
	logic [63:0] mem_data, mem_data_zero_ext, mem_mux1, mem_mux2, mem_data_result;
	logic [63:0] mux_data1, mux_data2, mux_data3, mux_data4; // Needed for mux between ALU data and memory data
	logic [63:0] data_out, mov_output;
	logic [4:0] reg_Ab, reg_result1, reg_result2;
	logic Reg2Loc_Not, MemToReg_Not, mov_Op_Not, mem_byte_Not;
	logic negative, zero, overflow, carryout;
	
	// logic wires from register bus 3
	logic [4:0] Rd_3;
	logic reg_writeEn_3;
	
	// Selector bits for forwarding muxs
	logic [1:0] mux_ReadData1, mux_ReadData2;
	
	// data result from forwarding muxs
	logic [63:0] ReadData1_res, ReadData2_res;
	
	// Pipeline logic wires
	logic [60:0] bus_combine1; // combine signals into a bus
	logic [12:0] bus_combine2;
	logic [5:0] bus_combine3;
	logic [60:0] register_bus1;
	logic [12:0] register_bus2;
	logic [5:0] register_bus3; // control signals to be recieved by registers from bus_combineN
	logic [63:0] regfile_data1, regfile_data2, mem_DataIn, data_out_reg, WriteData_res;
	logic clk_invert;
	
	
	genvar i, j, k, l, m, n, p, q;
	
	not #0.05 Reg2LocNot(Reg2Loc_Not, Reg2Loc);
	
	// inverted clock for regfile
	not #0.05 clkInvert(clk_invert, clk);
	
	// Mux for Reg2Loc
	generate
		for (i = 0; i < 5; i++) begin : Reg2LocMUX
			and #0.05 mux1_1(reg_result1[i], Rd[i], Reg2Loc_Not);
			and #0.05 mux1_2(reg_result2[i], Rm[i], Reg2Loc);
			or #0.05 mux1_3(reg_Ab[i], reg_result1[i], reg_result2[i]);
		end
	endgenerate
	
	// Get data from registers and possibly write data
	regfile registerfile(.ReadRegister1(Rn), .ReadRegister2(reg_Ab), .WriteRegister(Rd_3), 
									.WriteData(WriteData), .RegWrite(reg_writeEn_3), .clk(clk_invert), .ReadData1, .ReadData2);
									
	// mux between ReadData1 & 2 and ALU_result and WriteData_res	
	DataMux data1(.current_reg_data(ReadData1), .data_out, .WriteData(WriteData_res), .sel0(mux_ReadData1[0]), 
						.sel1(mux_ReadData1[1]), .ReadData_res(ReadData1_res));
						
	DataMux data2(.current_reg_data(ReadData2), .data_out, .WriteData(WriteData_res), .sel0(mux_ReadData2[0]), 
						.sel1(mux_ReadData2[1]), .ReadData_res(ReadData2_res));
	
	// Check if data is zero or not for accelerated branching
	zeroCheck ReadDataZeroCheck(.result(ReadData2_res), .zero(ReadData2_zero));
	
		
	// ID/EX REGISTER
	//Register 1. Combine all wires to send them between registers, send register data to next register and hold onto Rd for write
	assign bus_combine1 = {Rd[4:0], MemToReg, mem_writeEn, reg_writeEn, DAddr9[8:0], imm16[15:0], imm12[11:0], ALU_Op[2:0],
										mem_xfer[3:0], ALUSrc[1:0], im_shamt [1:0], set_flags, mov_type, mov_Op, mem_byte};
	generate
		for (m = 0; m < 60; m++) begin : registerID_EX
			D_FF registerIDEX(.q(register_bus1[m]), .d(bus_combine1[m]), .clk);
		end
		
		for (m = 0; m < 64; m++) begin : regfileData
			D_FF registerData1(.q(regfile_data1[m]), .d(ReadData1_res[m]), .clk);
			D_FF registerData2(.q(regfile_data2[m]), .d(ReadData2_res[m]), .clk);
		end
	endgenerate
	
	// logic wires from register bus
		logic [8:0] DAddr9_1;
		logic [15:0] imm16_1;
		logic [11:0] imm12_1;
		logic [4:0] Rd_1;
		logic [3:0] mem_xfer_1;
		logic [1:0] ALUSrc_1, im_shamt_1;
		logic [2:0] ALU_Op_1;
		logic set_flags_1, MemToReg_1, mem_writeEn_1, reg_writeEn_1, mov_type_1, mov_Op_1, mem_byte_1;
	
	// assign logic wires for readability
	always_comb begin
		DAddr9_1 = register_bus1[51:43];
		imm12_1 = register_bus1[26:15];
		ALUSrc_1 = register_bus1[7:6];
		ALU_Op_1 = register_bus1[14:12];
		set_flags_1 = register_bus1[3];
		Rd_1 = register_bus1[59:55];
		MemToReg_1 = register_bus1[54];
		mem_writeEn_1 = register_bus1[53];
		reg_writeEn_1 = register_bus1[52];
		imm16_1 = register_bus1[42:27];
		mem_xfer_1 = register_bus1[11:8];
		im_shamt_1 = register_bus1[5:4];
		mov_type_1 = register_bus1[2];
		mov_Op_1 = register_bus1[1];
		mem_byte_1 = register_bus1[0];
	end
	
	// sign extend DAddr9 & imm12 (zero extend)
	sign_ext #(9) DAddr9Ext(.input_bus(DAddr9_1), .output_bus(DAddr9_EXT), .sign_extension(DAddr9_1[8]));
	
	sign_ext #(12) imm12ZeroExt(.input_bus(imm12_1), .output_bus(imm12_EXT), .sign_extension(1'b0));
	
	// MUX for second input of ALU
	ALUSrcMUX MUX(.ReadData2(regfile_data2), .DAddr9_EXT, .imm12_EXT, .ALUSrc1(ALUSrc_1[0]), .ALUSrc2(ALUSrc_1[1]), .ALUData2);
	
	// Do ALU operations, output in ALU_result
	alu ALU(.A(regfile_data1), .B(ALUData2), .cntrl(ALU_Op_1), .result(ALU_result), .negative, .zero, .overflow, .carry_out(carryout));
	
	//update flags if set_flags is high !! TESTING USING INVERTED CLOCK
	update_flags update(.negative, .zero, .overflow, .carryout, .set_flags(set_flags_1), 
								.curr_negative, .curr_zero, .curr_overflow, .curr_carryout, .clk(clk_invert));
	
	mov_calc movOp(.Rd_data(ALU_result), .imm16(imm16_1), .shamt(im_shamt_1), .mov_type(mov_type_1), 
							.mov_output);

	not #0.05 MovOpNot(mov_Op_Not, mov_Op_1);
	
	//MUX between data_out and mov_output based on if it's a mov instruction or not. output to data_out
	generate
		for (k = 0; k < 64; k++) begin : MOVDATA_ALU_MUX
			and #0.05 (mux_data3[k], ALU_result[k], mov_Op_Not);
			and #0.05 (mux_data4[k], mov_output[k], mov_Op_1);
			or #0.05 (data_out[k], mux_data3[k], mux_data4[k]);
		end
	endgenerate
	
	// EX/MEM REGISTER						
	// Register 2, combine leftover signals (and Rd) and send them to next register
	//							 Rd[4:0], MemToReg, mem_writeEn, reg_writeEn, imm16[15:0], mem_xfer[3:0], im_shamt[1:0], mov_type, mov_Op, mem_byte
	assign bus_combine2 = {Rd_1[4:0], MemToReg_1, mem_writeEn_1, reg_writeEn_1, mem_xfer_1[3:0], mem_byte_1};
	
	generate 
		for (n = 0; n < 13; n++) begin : registerEX_MEM
			D_FF registerEXMEM(.q(register_bus2[n]), .d(bus_combine2[n]), .clk);
		end
		
		for (n = 0; n < 64; n++) begin : MemDataIn_ALU_res
			D_FF registerDataToMem(.q(mem_DataIn[n]), .d(regfile_data2[n]), .clk);
			D_FF registerALURes(.q(data_out_reg[n]), .d(data_out[n]), .clk);
		end
	endgenerate
	
	// logic wires from register bus
		logic [3:0] mem_xfer_2;
		logic [4:0] Rd_2;
		logic MemToReg_2, mem_writeEn_2, reg_writeEn_2, mem_byte_2;
	
	// assign logic wires for readability
	always_comb begin
		Rd_2 = register_bus2[12:8];
		MemToReg_2 = register_bus2[7];
		mem_writeEn_2 = register_bus2[6];
		reg_writeEn_2 = register_bus2[5];
		mem_xfer_2 = register_bus2[4:1];
		mem_byte_2 = register_bus2[0];
	end
	
	// Read from memory, output in mem_data
	datamem memory(.address(data_out_reg), .write_enable(mem_writeEn_2), .read_enable(1'b1), .write_data(mem_DataIn), 
							.clk, .xfer_size(mem_xfer_2), .read_data(mem_data));
	// Zero extend memory
	sign_ext #(8) mem_zero_ext(.input_bus(mem_data), .output_bus(mem_data_zero_ext), .sign_extension(1'b0));
	
	// Not signals for MUXs
	not #0.05 MemToRegNot(MemToReg_Not, MemToReg_2);
	not #0.05 MemByteNot(mem_byte_Not, mem_byte_2);
	
	// MUX between zero extended mem data and regular mem data
	generate
		for (l = 0; l < 64; l++) begin : Mem_data_MUX
			and #0.05 (mem_mux1[l], mem_data[l], mem_byte_Not);
			and #0.05 (mem_mux2[l], mem_data_zero_ext[l], mem_byte_2);
			or #0.05 (mem_data_result[l], mem_mux1[l], mem_mux2[l]);
		end
	endgenerate
							
	//MUX between data_out and mem_data
	generate
		for (j = 0; j < 64; j++) begin : mem_data_ALU_result_MUX
			and #0.05 (mux_data1[j], data_out_reg[j], MemToReg_Not);
			and #0.05 (mux_data2[j], mem_data_result[j], MemToReg_2);
			or #0.05 (WriteData_res[j], mux_data1[j], mux_data2[j]);
		end
	endgenerate
	
	// MEM/WR REGISTER
	// Send result of mux through register to send to regfile w/ Rd
	assign bus_combine3 = {Rd_2[4:0], reg_writeEn_2};
	generate
		for (p = 0; p < 64; p++) begin : WriteData_register
			D_FF WriteDataIn(.q(WriteData[p]), .d(WriteData_res[p]), .clk);
		end
		
		for (p = 0; p < 6; p++) begin : registerMEM_WRITE
			D_FF registerMEMWRITE(.q(register_bus3[p]), .d(bus_combine3[p]), .clk);
		end
	endgenerate
	
	// assign logic wires for readability
	always_comb begin
		Rd_3 = register_bus3[5:1];
		reg_writeEn_3 = register_bus3[0];
	end
	
	CPU_forwarding forward(.Rd_Ex(Rd_1), .Rd_Mem(Rd_2), .Reg_Aa(Rn), .Reg_Ab(reg_Ab), 
										.writeEn_Ex(reg_writeEn_1), .writeEn_Mem(reg_writeEn_2), .mux_ReadData1, .mux_ReadData2);
endmodule
			
			
			
			
			
			
			