module CPU_ctrl(reset, clk);
	// CPU will need a reset and clk to function correctly
	input logic reset, clk;
	
	// logic wires necessary for signals, register values, and immediate values
	logic [4:0] Rd, Rm, Rn;
	logic [11:0] imm12;
	logic [15:0] imm16;
	logic [8:0] DAddr9;
	logic [2:0] ALU_Op;
	logic Reg2Loc, MemToReg, UncondBr, BrTaken;
	logic [1:0] ALUSrc;
	logic reg_writeEn, mem_writeEn;
	logic flag_overflow, flag_negative, flag_carryout, flag_zero, set_flags, ReadData2_zero;
	logic [31:0] instruction;
	logic [3:0] mem_xfer;
	logic mem_byte;
	logic mov_type, mov_Op;
	
	logic [10:0] opcode;
	
	logic [25:0] BRAddr26;
	
	logic [18:0] CondAddr19;
	logic [4:0] cb_reg_cond;
	
	logic [4:0] r_Rm;
	logic [5:0] r_shamt;
	logic [4:0] r_Rn;
	logic [4:0] r_Rd;
	
	logic [11:0] i_imm12;
	logic [4:0] i_Rn;
	logic [4:0] i_Rd;
	
	logic [8:0] d_DAddr9;
	logic [4:0] d_Rn;
	logic [4:0] d_Rd;
	
	logic [4:0] im_Rd;
	logic [15:0] im_imm16;
	logic [1:0] im_shamt;
	
	
	parameter ALU_PASS_B=3'b000, ALU_ADD=3'b010, ALU_SUBTRACT=3'b011, ALU_AND=3'b100, ALU_OR=3'b101, ALU_XOR=3'b110;
	
	//Initialize the PC datapath
	CPU_data_PC PCDatapath(.UncondBr, .BrTaken, .CondAddr19, .BRAddr26, .instruction, .clk, .reset);
	
	
	// Block to assign wire values
	always_comb begin
	
		opcode = instruction[31:21];
	
		BRAddr26 = instruction[25:0];
		
		CondAddr19 = instruction[23:5];
		cb_reg_cond = instruction[4:0];
		
		r_Rm = instruction[20:16];
		// r_shamt = instruction[15:10]; not necessayr (I think)
		r_Rn = instruction[9:5];
		r_Rd = instruction[4:0];
		
		i_imm12 = instruction[21:10];
		i_Rn = instruction[9:5];
		i_Rd = instruction[4:0];
		
		DAddr9 = instruction[20:12];
		d_Rn = instruction[9:5];
		d_Rd = instruction[4:0];
		
		im_shamt = instruction[22:21];
		im_imm16 = instruction[20:5];
		im_Rd = instruction[4:0];
	end
	
	// assign signals based on opcode
	always_comb begin 
		Reg2Loc = 1'bx;
		ALUSrc = 2'bxx;
		ALU_Op = 3'bxxx;
		MemToReg = 1'bx;
		Rd = 5'bxxxxx;
		Rn = 5'bxxxxx;
		Rm = 5'bxxxxx;
		imm12 = 11'bxxxxxxxxxxx;
		imm16 = 15'bxxxxxxxxxxxxxxx;
		set_flags = 1'b0;
		mem_xfer = 3'bxxx;
		mem_byte = 1'bx;
		UncondBr	= 1'bx;
		mov_type = 1'bx;
		mov_Op = 1'bx;

		
		casez (opcode)
			// B branch
			11'b000101?????: begin
								  reg_writeEn = 1'b0;
								  mem_writeEn = 1'b0;
								  BrTaken = 1'b1;
								  UncondBr = 1'b1;
								  set_flags = 1'b0;
								  end


			// B.LT	
			11'b01010100???: begin
								  reg_writeEn = 1'b0;
								  mem_writeEn = 1'b0;
								  UncondBr = 1'b0;
								  BrTaken = (flag_negative != flag_overflow);
								  end
			//CBZ
			11'b10110100???: begin
								  Reg2Loc = 1'b0;
								  ALUSrc = 2'b00;
								  reg_writeEn = 1'b0;
								  mem_writeEn = 1'b0;
								  UncondBr = 1'b0;
								  ALU_Op = ALU_PASS_B;
								  BrTaken = ReadData2_zero;
								  Rd[4:0] = cb_reg_cond[4:0];
								  end
			


			//ADDS
			11'b10101011000: begin
								  Reg2Loc = 1'b1;
								  ALUSrc = 2'b00;
								  ALU_Op = ALU_ADD;
								  mem_writeEn = 1'b0;
								  MemToReg = 1'b0;
								  mov_Op = 1'b0;
								  reg_writeEn = 1'b1;
								  BrTaken = 1'b0;
								  UncondBr = 1'bx;
								  set_flags = 1'b1;
								  Rd[4:0] = r_Rd[4:0];
								  Rm[4:0] = r_Rm[4:0];
								  Rn[4:0] = r_Rn[4:0];
								  end
			//SUBS
			11'b11101011000: begin
								  Reg2Loc = 1'b1;
								  ALUSrc = 2'b00;
								  ALU_Op = ALU_SUBTRACT;
								  mem_writeEn = 1'b0;
								  MemToReg = 1'b0;
								  reg_writeEn = 1'b1;
								  mov_Op = 1'b0;
								  BrTaken = 1'b0;
								  UncondBr = 1'bx;
								  set_flags = 1'b1;
								  Rd[4:0] = r_Rd[4:0];
								  Rm[4:0] = r_Rm[4:0];
								  Rn[4:0] = r_Rn[4:0];
								  end

			//ADDI
			11'b1001000100?: begin
								  Reg2Loc = 1'b1;
								  ALUSrc = 2'b10;
								  ALU_Op = ALU_ADD;
								  mem_writeEn = 1'b0;
							     MemToReg = 1'b0;
								  reg_writeEn = 1'b1;
								  mov_Op = 1'b0;
								  BrTaken = 1'b0;
								  UncondBr = 1'bx;
								  set_flags = 1'b0;
								  Rn[4:0] = i_Rn[4:0];
								  Rd[4:0] = i_Rd[4:0];
								  imm12[11:0] = i_imm12[11:0];
								  end
		
		   //LDUR
			11'b11111000010: begin
								  Reg2Loc = 1'b0;
								  ALUSrc = 2'b01;
								  ALU_Op = ALU_ADD;
								  mem_writeEn = 1'b0;
								  MemToReg = 1'b1;
								  reg_writeEn = 1'b1;
								  mov_Op = 1'b0;
								  BrTaken = 1'b0;
								  mem_xfer = 4'b1000;
								  mem_byte = 1'b0;
								  Rd[4:0] = d_Rd[4:0];
								  Rn[4:0] = d_Rn[4:0];
								  end
			//LDURB
			11'b00111000010: begin
								  Reg2Loc = 1'b0;
								  ALUSrc = 2'b01;
								  ALU_Op = ALU_ADD;
								  mem_writeEn = 1'b0;
								  MemToReg = 1'b1;
								  reg_writeEn = 1'b1;
								  mov_Op = 1'b0;
								  BrTaken = 1'b0;
								  mem_xfer = 4'b0001;
								  mem_byte = 1'b1;
								  Rd[4:0] = d_Rd[4:0];
								  Rn[4:0] = d_Rn[4:0];
								  end
			//STUR
			11'b11111000000: begin
								  Reg2Loc = 1'b0;
								  ALUSrc = 2'b01;
								  ALU_Op = ALU_ADD;
								  mem_writeEn = 1'b1;
								  reg_writeEn = 1'b0;
								  BrTaken = 1'b0;
								  mov_Op = 1'b0;
								  mem_xfer = 4'b1000;
								  mem_byte = 1'b0;
								  Rd[4:0] = d_Rd[4:0];
								  Rn[4:0] = d_Rn[4:0];
								  end
			//STURB
			11'b00111000000: begin
								  Reg2Loc = 1'b0;
								  ALUSrc = 2'b01;
								  ALU_Op = ALU_ADD;
								  mem_writeEn = 1'b1;
								  reg_writeEn = 1'b0;
								  BrTaken = 1'b0;
								  mov_Op = 1'b0;
								  mem_xfer = 4'b0001;
								  mem_byte = 1'b1;
								  Rd[4:0] = d_Rd[4:0];
								  Rn[4:0] = d_Rn[4:0];
								  end
			//MOVZ
			11'b110100101??: begin
								  reg_writeEn = 1'b1;
								  mem_writeEn = 1'b0;
								  mov_Op = 1'b1;
								  mov_type = 1'b1;
								  MemToReg = 1'b0;
								  BrTaken = 1'b0;
								  Rd[4:0] = im_Rd[4:0];
								  imm16 = im_imm16[15:0];
								  end
								  
			//MOVK
			11'b111100101??: begin
								  Reg2Loc = 1'b0;
								  ALUSrc = 2'b00;
								  ALU_Op = ALU_PASS_B;
								  MemToReg = 1'b0;
								  mem_writeEn = 1'b0;
								  reg_writeEn = 1'b1;
								  mov_type = 1'b0;
								  mov_Op = 1'b1;
								  BrTaken = 1'b0;
								  Rd[4:0] = im_Rd[4:0];
								  imm16[15:0] = im_imm16[15:0];
								  end
		default: begin 
					BrTaken = 1'b0;
					UncondBr = 1'bx;
					mem_writeEn = 1'b0;
					reg_writeEn = 1'b0;
					Rd = 5'bxxxxx;
					Rn = 5'bxxxxx;
					Rm = 5'bxxxxx;
					imm12 = 11'bxxxxxxxxxxx;
					imm16 = 15'bxxxxxxxxxxxxxxx;
					Reg2Loc = 1'bx;
					ALUSrc = 2'bxx;
					ALU_Op = 3'bxxx;
					MemToReg = 1'bx;
					mov_type = 1'bx;
					mov_Op = 1'bx;
					end
		endcase			 
	end
	
	
	// Initialize main datapath
	CPU_data main(.Rd, .Rm, .Rn, .DAddr9, .imm12, .imm16, .Reg2Loc, .ALUSrc, .ALU_Op, .MemToReg, 
						.mem_writeEn, .reg_writeEn, .set_flags, .curr_negative(flag_negative), .curr_zero(flag_zero), 
						.curr_overflow(flag_overflow), .curr_carryout(flag_carryout), .ReadData2_zero, .mem_xfer, 
						.mem_byte, .im_shamt, .mov_type, .mov_Op, .clk);

endmodule
