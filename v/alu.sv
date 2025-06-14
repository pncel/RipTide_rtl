`timescale 1ps/100fs
// Bernardo Lin
// RipTide ALU

// Supporting all operations mentioned in the paper including shifting and comparisons
// This is the top module of the Arithmetic logical unit

// Meaning of signals in and out of the ALU:

// Flags:
// negative: whether the result output is negative if interpreted as 2's comp.
// zero: whether the result output was a 64-bit zero.
// overflow: on an add or subtract, whether the computation overflowed if the inputs are interpreted as 2's comp.
// carry_out: on an add or subtract, whether the computation produced a carry-out.

// cntrl			Operation						Notes:
// 000:			result = B						value of overflow and carry_out unimportant
// 001:			result = A + B
// 010:			result = A - B
// 011:			result = bitwise A & B		value of overflow and carry_out unimportant
// 100:			result = bitwise A | B		value of overflow and carry_out unimportant
// 101:			result = bitwise A XOR B	value of overflow and carry_out unimportant
// 110:			Shifting operations
    // 00:      result = A << B[5:0]; logical left shift, the reason it's B[5:0] it's because that way we can limit the number to 0~63 bits when shifting
    // 01:      result = A >> B[5:0]; logical right shift
    // 10:      result = $signed(A) >>> B[5:0]; arithmetic right shift
// 111:			Comparisons
    // 00:      result = (A == B)
    // 01:      result = (A > B)
    // 10:      result = (A < B)
    // 11:      result = (A >= B) 

module alu(A, B, cntrl, shift_cntrl, cmp_cntrl, result, negative, zero, overflow, carry_out);
	input [63:0] A, B;
	input [2:0] cntrl, shift_cntrl, cmp_cntrl;
	output [63:0] result;
	output logic negative, zero, overflow, carry_out;
	logic[63:0] pass_b, and_result, or_result, xor_result, add_sub_result;
	genvar i;
	
	assign pass_b = B;
	
	bt_and bit_and(.a(A) ,.b(B) ,.result(and_result));
	bt_or bit_or(.a(A) ,.b(B) ,.result(or_result));
	bt_xor bit_xor(.a(A) ,.b(B) ,.result(xor_result));
	bt_64_full_adder bit_64_adder(.a(A),.b(B),.default_cin(cntrl[0]),.result(add_sub_result),.cout(carry_out),.overflow(overflow));

     // Logical left shift, use lower 6 bits of B (0-63)
    assign lshift_result = A << B[5:0];

    // Logical right shift
    assign rshift_result = A >> B[5:0];
	
	always_comb begin
		case (cntrl)
            3'b000: // Pass B 
                result = B;     
			3'b001:   // Addition
                result = add_sub_result; 
			3'b010:  // Subtraction
                result = add_sub_result;    
			3'b011:  // Bitwise AND
                result = and_result;     
			3'b100:  // Bitwise OR
                result = or_result;                
			3'b101:  // Bitwise XOR
                result = xor_result;                
            3'b110: begin //shifting
                case (shift_cntrl)
                    2'b00: // Logical left shift
                        result = A << B[5:0];           
                    2'b01: // Logical right shift
                        result = A >> B[5:0];           
                    2'b10: // Arithmetic right shift
                        result = $signed(A) >>> B[5:0];
                    2 'b11;
                        result = 64'h0;
                    default:  // No shift
                        result = 64'h0;              
                endcase
            end
			3'b111: begin
                case (cmp_cntrl)
                    2'b00: // Equality
                        result = (A == B) ? 64'h1 : 64'h0; 
                    2'b01: // Greater-than
                        result = (A > B) ? 64'h1 : 64'h0;  
                    2'b10: // Less-than
                        result = (A < B) ? 64'h1 : 64'h0;  
                    2'b11: // Greater-than-or-equal-to
                        result = (A >= B) ? 64'h1 : 64'h0; 
                    default: // Default 
                        result = 64'h0;                  
                endcase
            end
			default: 
                result = 64'b0;
		endcase
	end
	
	zero_detector zero_detection(.result(result),.zero_detected(zero));
	assign negative = result[63];
	
endmodule



// Test bench for ALU
`timescale 1ns/10ps

module alustim();

	parameter delay = 100000;

	logic		[63:0]	A, B;
	logic		[2:0]		cntrl;
	logic		[63:0]	result;
	logic					negative, zero, overflow, carry_out ;

	parameter ALU_PASS_B=3'b000, ALU_ADD=3'b001, ALU_SUBTRACT=3'b010, ALU_AND=3'b011, ALU_OR=3'b100, ALU_XOR=3'b101;
	

	alu dut (.A, .B, .cntrl, .result, .negative, .zero, .overflow, .carry_out);

	// Force %t's to print in a nice format.
	initial $timeformat(-9, 2, " ns", 10);

	integer i;
	logic [63:0] test_val;
	initial begin
	
		$display("%t testing PASS_B operations", $time);
		cntrl = ALU_PASS_B;
		for (i=0; i<100; i++) begin
			A = $random(); B = $random();
			#(delay);
			assert(result == B && negative == B[63] && zero == (B == '0));
		end
		
		$display("%t testing addition", $time);
		cntrl = ALU_ADD;
		for (i=0; i<100; i++) begin
			A = 64'h0000000000000001; B = 64'h0000000000000001;
			#(delay);
			assert(result == 64'h0000000000000002 && carry_out == 0 && overflow == 0 && negative == 0 && zero == 0);
		end
		
		for (i=0; i<100; i++) begin
			A = 64'hFFFFFFFFFFFFFFFF; B = 64'hFFFFFFFFFFFFFFFF;
			#(delay);
			assert(result == 64'hFFFFFFFFFFFFFFFE && carry_out == 1 && overflow == 0 && negative == 1 && zero == 0);
		end
		
		$display("%t testing subtraction", $time);
		cntrl = ALU_SUBTRACT;
		for (i=0; i<100; i++) begin
			A = 64'h0001000100010100; B = 64'h0010010000000001;
			#(delay);
		end
		
		$display("%t testing and", $time);
		cntrl = ALU_AND;
		for (i=0; i<100; i++) begin
			A = 64'h0001000100010100; B = 64'h0010010000000001;
			#(delay);
			assert(result == 0 && carry_out == 0 && overflow == 0 && negative == 0 && zero == 1);
		end
		
		$display("%t testing and", $time);
		cntrl = ALU_AND;
		for (i=0; i<100; i++) begin
			A = 64'h1111111111111111; B = 64'h1111111111111111;
			#(delay);
			assert(result == 64'h1111111111111111 && carry_out == 0 && overflow == 0 && negative == 0 && zero == 0);
		end
		
		$display("%t testing or", $time);
		cntrl = ALU_OR;
		for (i=0; i<100; i++) begin
			A = 64'h1111111111111111; B = 64'h1111111111111111;
			#(delay);
			assert(result == 64'h1111111111111111 && carry_out == 1 && overflow == 0 && negative == 0 && zero == 0);
		end
		
		$display("%t testing or", $time);
		cntrl = ALU_OR;
		for (i=0; i<100; i++) begin
			A = 64'h0000000000000001; B = 64'h1111111111111111;
			#(delay);
			assert(result == 64'h1111111111111111 && carry_out == 0 && overflow == 0 && negative == 0 && zero == 0);
		end
	end
endmodule