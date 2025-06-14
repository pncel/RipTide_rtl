`timescale 1ps/100fs

// Bernardo Lin
// One of the submodules for the alu, can also be used in other modules as well if needed.
// A 8 to 1 mux that outputs the selected input(a, b, c, d...etc.) through the select signal

module mux8to1(a, b, c, d, e, f, g, h, s0, s1, s2, y);
	input logic a, b, c, d, e, f, g, h, s0, s1, s2;
	output logic y;
	logic m1_out, m2_out;
	
	mux4to1 mux0 (.a(a), .b(b), .c(c), .d(d), .s0(s0), .s1(s1), y(m1_out));
	mux4to1 mux1 (.a(e), .b(f), .c(g), .d(h), .s0(s0), .s1(s1), y(m2_out));
	mux2to1 mux2 (.d0(m1_out), .d1(m2_out), .select(s2), .y(y));
	
endmodule