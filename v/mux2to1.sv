// Bernardo Lin
// One of the submodules for the alu, can also be used in other modules as well if needed.
// A 2 to 1 mux that outputs the selected input(a, b..etc.) through the select signal

module mux2to1(d0, d1, select, y);
	input logic d0, d1, select;
	output logic y;
	logic gate1, gate2, notselect;
	
	not #(50) not_select(notselect, select);
	and #(50) result1 (gate1, notselect, d0);
	and #(50) result2 (gate2, d1, select);
	or #(50) final_result (y, gate1, gate2);
	
endmodule