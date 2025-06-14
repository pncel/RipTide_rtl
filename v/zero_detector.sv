`timescale 1ps/100fs

// Bernardo Lin
// One of the submodules for the alu
// It's the module that sets the zero flag for the alu where we determine whether if the input is all 0s and return 1 if it's true

module zero_detector(result, zero_detected);
	input [63:0] result;
	output logic zero_detected;
	
	logic [15:0] nor1;
	logic [3:0] and2;
	genvar i;
	generate
		for(i = 0; i < 16; i++) begin: nor1_assign
			nor #(50) nor_gate_assign (nor1[i], result[4 * i], result[4 * i + 1], result[4 * i + 2], result [4 * i + 3]);
		end
	endgenerate
	and #(50) and_assign1(and2[0], nor1[0], nor1[1], nor1[2], nor1[3]);
   and #(50) and_assign2(and2[1], nor1[4], nor1[5], nor1[6], nor1[7]);
   and #(50) and_assign3(and2[2], nor1[8], nor1[9], nor1[10], nor1[11]);
   and #(50) and_assign4(and2[3], nor1[12], nor1[13], nor1[14], nor1[15]);
	
	and #(50) and_final_assign(zero_detected, and2[0], and2[1], and2[2], and2[3]);
endmodule