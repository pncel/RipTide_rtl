`timescale 1ps/100fs

// Bernardo Lin
// One of the submodules for the alu
// It's the module that does the bitwise and operation

module bt_and(a, b, result);
	input [63:0] a, b;
	output [63:0] result;
	genvar i;
	generate
		for(i = 0; i < 64; i++) begin:eachRegs
			and #(50) and_gate (result[i], a[i], b[i]);
		end
	endgenerate
	
endmodule