// Bernardo Lin
// One of the submodules for the alu, can also be used in other modules as well if needed.
// A 4 to 1 mux that outputs the selected input(a, b, c, d...etc.) through the select signal

module mux4to1(a, b, c, d, s0, s1, y);
    input logic a, b, c, d, s0, s1;
    output logic y;
    logic y1, y2;

    mux2to1 (.d0(a), .d1(b), .select(s0), .y(y1));
    mux2to1 (.d0(c), .d1(d), .select(s0), .y(y2));
    mux2to1 (.d0(y1), .d1(y2), .select(s1), .y(y));
endmodule