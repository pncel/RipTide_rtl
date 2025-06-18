// Keith Phou

// ALU Testbench
// Tests all operations and flag conditions

`timescale 1ns/1ps

module fu_alu_tb();

    logic [63:0] A, B;
    logic [2:0] cntrl;
    logic [63:0] result;
    logic negative, zero, overflow, carry_out;
    
    // Test tracking
    int test_count = 0;
    int pass_count = 0;
    
    fu_alu dut (
        .A(A),
        .B(B),
        .cntrl(cntrl),
        .result(result),
        .negative(negative),
        .zero(zero),
        .overflow(overflow),
        .carry_out(carry_out)
    );
    
    // Test case task
    task automatic test_case(
        input [63:0] test_A,
        input [63:0] test_B,
        input [2:0] test_cntrl,
        input [63:0] expected_result,
        input expected_negative,
        input expected_zero,
        input expected_overflow,
        input expected_carry_out,
        input string test_name
    );
        test_count++;
        A = test_A;
        B = test_B;
        cntrl = test_cntrl;
        
        #10; // Wait
        
        // Check results
        if (result === expected_result && 
            negative === expected_negative &&
            zero === expected_zero &&
            overflow === expected_overflow &&
            carry_out === expected_carry_out) begin
            $display("✓ PASS: %s", test_name);
            pass_count++;
        end else begin
            $display("✗ FAIL: %s", test_name);
            $display("  Expected: result=%h, neg=%b, zero=%b, ovf=%b, cout=%b", 
                     expected_result, expected_negative, expected_zero, expected_overflow, expected_carry_out);
            $display("  Got:      result=%h, neg=%b, zero=%b, ovf=%b, cout=%b", 
                     result, negative, zero, overflow, carry_out);
        end
    endtask
    
    initial begin
        $display("=== ALU Testbench Starting ===");
        
        // ===== PASS B TESTS (cntrl = 000) =====
        $display("\n--- Testing Pass B Operation (000) ---");
        test_case(64'h1234567890ABCDEF, 64'h0000000000000000, 3'b000, 64'h0000000000000000, 1'b0, 1'b1, 1'b0, 1'b0, "Pass B - zero");
        test_case(64'h1234567890ABCDEF, 64'hFEDCBA0987654321, 3'b000, 64'hFEDCBA0987654321, 1'b1, 1'b0, 1'b0, 1'b0, "Pass B - negative");
        test_case(64'h1234567890ABCDEF, 64'h7FFFFFFFFFFFFFFF, 3'b000, 64'h7FFFFFFFFFFFFFFF, 1'b0, 1'b0, 1'b0, 1'b0, "Pass B - positive");
        
        // ===== ADDITION TESTS (cntrl = 010) =====
        $display("\n--- Testing Addition (010) ---");
        test_case(64'h0000000000000005, 64'h0000000000000003, 3'b010, 64'h0000000000000008, 1'b0, 1'b0, 1'b0, 1'b0, "Add: 5 + 3 = 8");
        test_case(64'h0000000000000000, 64'h0000000000000000, 3'b010, 64'h0000000000000000, 1'b0, 1'b1, 1'b0, 1'b0, "Add: 0 + 0 = 0 (zero flag)");
        test_case(64'hFFFFFFFFFFFFFFFF, 64'h0000000000000001, 3'b010, 64'h0000000000000000, 1'b0, 1'b1, 1'b0, 1'b1, "Add: max + 1 = 0 (carry)");
        test_case(64'h7FFFFFFFFFFFFFFF, 64'h0000000000000001, 3'b010, 64'h8000000000000000, 1'b1, 1'b0, 1'b1, 1'b0, "Add: positive overflow");
        test_case(64'h8000000000000000, 64'hFFFFFFFFFFFFFFFF, 3'b010, 64'h7FFFFFFFFFFFFFFF, 1'b0, 1'b0, 1'b1, 1'b1, "Add: negative overflow");
        
        // ===== SUBTRACTION TESTS (cntrl = 011) =====
        $display("\n--- Testing Subtraction (011) ---");
        test_case(64'h0000000000000008, 64'h0000000000000003, 3'b011, 64'h0000000000000005, 1'b0, 1'b0, 1'b0, 1'b1, "Sub: 8 - 3 = 5");
        test_case(64'h0000000000000005, 64'h0000000000000005, 3'b011, 64'h0000000000000000, 1'b0, 1'b1, 1'b0, 1'b1, "Sub: 5 - 5 = 0 (zero)");
        test_case(64'h0000000000000003, 64'h0000000000000008, 3'b011, 64'hFFFFFFFFFFFFFFFB, 1'b1, 1'b0, 1'b0, 1'b0, "Sub: 3 - 8 = -5 (negative)");
        test_case(64'h8000000000000000, 64'h0000000000000001, 3'b011, 64'h7FFFFFFFFFFFFFFF, 1'b0, 1'b0, 1'b1, 1'b1, "Sub: underflow");
        test_case(64'h7FFFFFFFFFFFFFFF, 64'hFFFFFFFFFFFFFFFF, 3'b011, 64'h8000000000000000, 1'b1, 1'b0, 1'b1, 1'b0, "Sub: overflow");
        
        // ===== BITWISE AND TESTS (cntrl = 100) =====
        $display("\n--- Testing Bitwise AND (100) ---");
        test_case(64'hFFFFFFFFFFFFFFFF, 64'h0000000000000000, 3'b100, 64'h0000000000000000, 1'b0, 1'b1, 1'b0, 1'b0, "AND: all 1s & all 0s = 0");
        test_case(64'hFFFFFFFFFFFFFFFF, 64'hFFFFFFFFFFFFFFFF, 3'b100, 64'hFFFFFFFFFFFFFFFF, 1'b1, 1'b0, 1'b0, 1'b0, "AND: all 1s & all 1s = all 1s");
        test_case(64'hAAAAAAAAAAAAAAAA, 64'h5555555555555555, 3'b100, 64'h0000000000000000, 1'b0, 1'b1, 1'b0, 1'b0, "AND: alternating bits");
        test_case(64'h123456789ABCDEF0, 64'hF0E1D2C3B4A59687, 3'b100, 64'h1020527890A49680, 1'b0, 1'b0, 1'b0, 1'b0, "AND: mixed pattern");
        
        // ===== BITWISE OR TESTS (cntrl = 101) =====
        $display("\n--- Testing Bitwise OR (101) ---");
        test_case(64'h0000000000000000, 64'h0000000000000000, 3'b101, 64'h0000000000000000, 1'b0, 1'b1, 1'b0, 1'b0, "OR: 0 | 0 = 0");
        test_case(64'hFFFFFFFFFFFFFFFF, 64'h0000000000000000, 3'b101, 64'hFFFFFFFFFFFFFFFF, 1'b1, 1'b0, 1'b0, 1'b0, "OR: all 1s | 0 = all 1s");
        test_case(64'hAAAAAAAAAAAAAAAA, 64'h5555555555555555, 3'b101, 64'hFFFFFFFFFFFFFFFF, 1'b1, 1'b0, 1'b0, 1'b0, "OR: alternating bits");
        test_case(64'h123456789ABCDEF0, 64'hF0E1D2C3B4A59687, 3'b101, 64'hF2F5D6FBB6BDDEF7, 1'b1, 1'b0, 1'b0, 1'b0, "OR: mixed pattern");
        
        // ===== BITWISE XOR TESTS (cntrl = 110) =====
        $display("\n--- Testing Bitwise XOR (110) ---");
        test_case(64'h0000000000000000, 64'h0000000000000000, 3'b110, 64'h0000000000000000, 1'b0, 1'b1, 1'b0, 1'b0, "XOR: 0 ^ 0 = 0");
        test_case(64'hFFFFFFFFFFFFFFFF, 64'hFFFFFFFFFFFFFFFF, 3'b110, 64'h0000000000000000, 1'b0, 1'b1, 1'b0, 1'b0, "XOR: same values = 0");
        test_case(64'hAAAAAAAAAAAAAAAA, 64'h5555555555555555, 3'b110, 64'hFFFFFFFFFFFFFFFF, 1'b1, 1'b0, 1'b0, 1'b0, "XOR: alternating bits");
        test_case(64'h123456789ABCDEF0, 64'hF0E1D2C3B4A59687, 3'b110, 64'hE2D584BB2E194977, 1'b1, 1'b0, 1'b0, 1'b0, "XOR: mixed pattern");
        
        // ===== EDGE CASE TESTS =====
        $display("\n--- Testing Edge Cases ---");
        test_case(64'h0000000000000001, 64'hFFFFFFFFFFFFFFFF, 3'b010, 64'h0000000000000000, 1'b0, 1'b1, 1'b0, 1'b1, "Edge: 1 + (-1) = 0");
        test_case(64'h8000000000000000, 64'h8000000000000000, 3'b010, 64'h0000000000000000, 1'b0, 1'b1, 1'b1, 1'b1, "Edge: min + min = 0 (overflow)");
        
        // ===== INVALID CONTROL TESTS =====
        $display("\n--- Testing Invalid Control Values ---");
        test_case(64'h1234567890ABCDEF, 64'hFEDCBA0987654321, 3'b001, 64'h0000000000000000, 1'b0, 1'b1, 1'b0, 1'b0, "Invalid control 001");
        test_case(64'h1234567890ABCDEF, 64'hFEDCBA0987654321, 3'b111, 64'h0000000000000000, 1'b0, 1'b1, 1'b0, 1'b0, "Invalid control 111");
        
        // ===== FINAL RESULTS =====
        $display("\n=== Test Results ===");
        $display("Tests Run: %0d", test_count);
        $display("Tests Passed: %0d", pass_count);
        $display("Tests Failed: %0d", test_count - pass_count);
        
        if (pass_count == test_count) begin
            $display("ALL TESTS PASSED!");
        end else begin
            $display("SOME TESTS FAILED");
        end
        
        $finish;
    end
    
endmodule