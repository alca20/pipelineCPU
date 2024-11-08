`timescale 1ns/10ps
module update_flags (negative, zero, overflow, carryout, set_flags, 
								curr_negative, curr_zero, curr_overflow, curr_carryout, clk);
	input logic negative, zero, overflow, carryout, set_flags, clk;
	output logic curr_negative, curr_zero, curr_overflow, curr_carryout;
	
	logic [3:0] result1, result2, data_to_send;
	logic set_flags_not;
	
	not #0.05 set_flagsNOT(set_flags_not, set_flags);
	
	//mux for negative
	and #0.05 negativeMux1(result1[0], curr_negative, set_flags_not);
	and #0.05 negativeMux2(result2[0], negative, set_flags);
	or #0.05 negativeMux3(data_to_send[0], result1[0], result2[0]);
	D_FF negativeFF(.q(curr_negative), .d(data_to_send[0]), .clk(clk));
	
	//mux for zero
	and #0.05 zeroMux1(result1[1], curr_zero, set_flags_not);
	and #0.05 zeroMux2(result2[1], zero, set_flags);
	or #0.05 zeroMux3(data_to_send[1], result1[1], result2[1]);
	D_FF zeroFF(.q(curr_zero), .d(data_to_send[1]), .clk(clk));
	
	//mux for overflow
	and #0.05 overflowMux1(result1[2], curr_overflow, set_flags_not);
	and #0.05 overflowMux2(result2[2], overflow, set_flags);
	or #0.05 overflowMux3(data_to_send[2], result1[2], result2[2]);
	D_FF overflowFF(.q(curr_overflow), .d(data_to_send[2]), .clk(clk));
	
	//mux for carryout
	and #0.05 carryoutMux1(result1[3], curr_carryout, set_flags_not);
	and #0.05 carryoutMux2(result2[3], carryout, set_flags);
	or #0.05 carryoutMux3(data_to_send[3], result1[3], result2[3]);
	D_FF carryoutFF(.q(curr_carryout), .d(data_to_send[3]), .clk(clk));
	
endmodule 