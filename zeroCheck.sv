`timescale 1ns/10ps

module zeroCheck(result, zero);
	input logic [63:0] result;
	output logic zero;
	
	logic [15:0] norResult;
	logic [3:0] andResult;
	
	genvar i, j;
	
	generate
		// First level, check if all bits are zero
		for (i = 0; i < 16; i++) begin : NORgen
			nor #0.05 result1(norResult[i], result[i*4], result[i*4 + 1], result[i*4 + 2],
									result[i*4 + 3]);
		end
		
		// Second level, check if all NOR gates were true
		for (j = 0; j < 4; j++) begin : ANDgen
			and #0.05 result2(andResult[j], norResult[j*4], norResult[j*4 + 1], norResult[j*4 + 2],
									norResult[j*4 + 3]);
		end
	endgenerate
	
	// Set the zero flag by checking if all AND gates were true
	and #0.05 zeroFlag(zero, andResult[0], andResult[1], andResult[2], andResult[3]);
endmodule