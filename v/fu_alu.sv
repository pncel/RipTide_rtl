// Keith Phou
// ALU

// Function:
// Top level design of the ALU with all logic integrated

// Meaning of signals in and out of the ALU:

// Flags:
// negative: whether the result output is negative if interpreted as 2's comp.
// zero: whether the result output was a 64-bit zero.
// overflow: on an add or subtract, whether the computation overflowed if the inputs are interpreted as 2's comp.
// carry_out: on an add or subtract, whether the computation produced a carry-out.

// cntrl			Operation						Notes:
// 000:			result = B						value of overflow and carry_out unimportant
// 010:			result = A + B
// 011:			result = A - B
// 100:			result = bitwise A & B		value of overflow and carry_out unimportant
// 101:			result = bitwise A | B		value of overflow and carry_out unimportant
// 110:			result = bitwise A XOR B	value of overflow and carry_out unimportant

module fu_alu (A, B, cntrl, result, negative, zero, overflow, carry_out);

	input logic	[63:0] A, B;
	input logic	[2:0] cntrl;
	output logic [63:0] result;
	output logic negative, zero, overflow, carry_out;
	
	// Internal signals for arithmetic operations
	logic [63:0] B_modified;  // B or ~B for subtraction
	logic cin_initial;        // Initial carry in
	logic [64:0] add_result;  // Extended result for carry detection
	
	// Determine B input and initial carry based on operation
	always_comb begin
		case (cntrl)
			3'b010: begin  // Addition
				B_modified = B;
				cin_initial = 1'b0;
			end
			3'b011: begin  // Subtraction (A - B = A + ~B + 1)
				B_modified = ~B;
				cin_initial = 1'b1;
			end
			default: begin
				B_modified = B;
				cin_initial = 1'b0;
			end
		endcase
	end
	
	// Perform addition for arithmetic operations
	assign add_result = A + B_modified + cin_initial;
	
	// Main ALU operation selection
	always_comb begin
		case (cntrl)
			3'b000:  result = B;                    // Pass B
			3'b010:  result = add_result[63:0];     // Addition
			3'b011:  result = add_result[63:0];     // Subtraction
			3'b100:  result = A & B;                // Bitwise AND
			3'b101:  result = A | B;                // Bitwise OR
			3'b110:  result = A ^ B;                // Bitwise XOR
			default: result = 64'b0;
		endcase
	end
	
	// Flag generation
	always_comb begin
		// Negative flag: MSB of result
		negative = result[63];
		
		// Zero flag: result is all zeros
		zero = (result == 64'b0);
		
		// Overflow flag: only meaningful for add/subtract
		// Overflow occurs when both operands have same sign but result has different sign
		if (cntrl == 3'b010 || cntrl == 3'b011) begin
			overflow = (A[63] == B_modified[63]) && (A[63] != result[63]);
		end else begin
			overflow = 1'b0;  // Not meaningful for other operations
		end
		
		// Carry out flag: only meaningful for add/subtract
		if (cntrl == 3'b010 || cntrl == 3'b011) begin
			carry_out = add_result[64];
		end else begin
			carry_out = 1'b0;  // Not meaningful for other operations
		end
	end
	
endmodule