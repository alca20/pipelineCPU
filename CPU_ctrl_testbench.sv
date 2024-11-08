`timescale 1ns/10ps
module CPU_ctrl_testbench();
	parameter ClockDelay = 500000;
	logic reset, clk;
	CPU_ctrl dut(.reset, .clk);
	
	initial begin // Set up the clock
		clk <= 0;
		forever #(ClockDelay/2) clk <= ~clk;
	end
	
	initial begin
		@(posedge clk); reset = 1'b1;
		@(posedge clk); reset = 1'b0;
		@(posedge clk);
		@(posedge clk);
		repeat (128)
			@(posedge clk);
	end
	
	

endmodule