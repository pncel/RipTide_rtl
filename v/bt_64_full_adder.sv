`timescale 1ps/100fs

// Bernardo Lin
// One of the submodules for the alu, can also be used in other modules as well if needed.
// A 64 bitwise full adder that functions as a full adder, but for 2 64 bit inputs through utilizing the 1 bit full adder submodule and logic gates

module bt_64_full_adder(a, b, default_cin, result, cout, overflow);
	input [63:0] a, b;
	input logic default_cin;
	output [63:0] result;
	output logic cout, overflow;
	logic [63:0] carry_storage, updated_b;
	logic not_a, not_b, of1_result, of2_result, not_result, of_detected;
	genvar i;
	
	generate
		for(i = 0; i < 64; i++) begin: replicate
			xor #(50) xor_gate (updated_b[i], default_cin, b[i]);
		end
	endgenerate
	
	bt_full_adder full_adder0 (.a(a[0]),.b(updated_b[0]),.cin(default_cin),.sum(result[0]) ,.cout(carry_storage[0]));
	
	generate
		for(i = 1; i < 64; i++) begin:each_adder
			bt_full_adder full_adder (.a(a[i]),.b(updated_b[i]),.cin(carry_storage[i-1]),.sum(result[i]) ,.cout(carry_storage[i]));
		end
	endgenerate
	
	not #(50) not_gate_a (not_a, a[63]);
	not #(50) not_gate_b (not_b, updated_b[63]);
	not #(50) not_gate_result (not_result, result[63]);
	and #(50) and_gate_of1(of1_result, not_a, not_b, result[63]);
	and #(50) and_gate_of2(of2_result, a[63], updated_b[63], not_result);
	or #(50) or_gate_final(of_detected, of1_result, of2_result);
	
	
	assign cout = carry_storage[63];
	assign overflow = of_detected;
	
endmodule
