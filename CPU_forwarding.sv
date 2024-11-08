module CPU_forwarding(Rd_Ex, Rd_Mem, Reg_Aa, Reg_Ab, writeEn_Ex, writeEn_Mem, mux_ReadData1, mux_ReadData2);
	input logic [4:0] Rd_Ex, Rd_Mem, Reg_Aa, Reg_Ab;
	input logic writeEn_Ex, writeEn_Mem;
	output logic [1:0] mux_ReadData1, mux_ReadData2;
	
	// 2'b10 = Execute stage data, 2'b11 = Mem stage data, 2'b00 = Register fetch stage
	always_comb begin
		if (Reg_Aa == 5'b11111) 
			mux_ReadData1 = 2'b00;
		else if ((Reg_Aa == Rd_Ex) && (writeEn_Ex == 1'b1))
			mux_ReadData1 = 2'b10;
		else if ((Reg_Aa == Rd_Mem) && (writeEn_Mem == 1'b1))
			mux_ReadData1 = 2'b11;
		else mux_ReadData1 = 2'b00;
		
		if (Reg_Ab == 5'b11111) 
			mux_ReadData2 = 2'b00;
		else if ((Reg_Ab == Rd_Ex) && (writeEn_Ex == 1'b1))
			mux_ReadData2 = 2'b10;
		else if ((Reg_Ab == Rd_Mem) && (writeEn_Mem == 1'b1))
			mux_ReadData2 = 2'b11;
		else mux_ReadData2 = 2'b00;
	end
endmodule 