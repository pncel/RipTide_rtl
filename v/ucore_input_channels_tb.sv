// Keith Phou

// RipTide ucore input channels
// Based on the paper: "RipTide: A programmable, energy-minimal dataflow compiler and architecture"
// This module is a part of the ucore
// Testbench 

`timescale 1ns/1ps
module ucore_input_channels_tb;
    // Parameters
    localparam DATA_WIDTH = 32;
    localparam N = 2;
    localparam INPUT_BUFFER_DEPTH = 2;
    
    // Testbench signals
    logic clk;
    logic rst_n;
    logic noc_ivalid;
    logic [DATA_WIDTH-1:0] noc_in;
    logic noc_oready;
    logic [DATA_WIDTH-1:0] out;
    
    // Instantiate the Unit Under Test (UUT)
    ucore_input_channels #(
        .DATA_WIDTH(DATA_WIDTH),
        .N(N),
        .INPUT_BUFFER_DEPTH(INPUT_BUFFER_DEPTH)
    ) uut (
        .clk(clk),
        .rst_n(rst_n),
        .noc_ivalid(noc_ivalid),
        .noc_in(noc_in),
        .noc_oready(noc_oready),
        .out(out)
    );
    
    // Clock period
    localparam CLK_PERIOD = 100; // 100ns (100MHz)

    // Clock generation
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end
    
    // Test stimulus
    initial begin
        // Initialize inputs
        rst_n = 0;
        noc_ivalid = 0;
        noc_in = 0;
        
        // Wait for global reset
        #(CLK_PERIOD*2);
        rst_n = 1;
        #CLK_PERIOD;
        
        // Test Case 1: Basic write and read operation
        $display("Test Case 1: Basic write and read operation");
        
        // Write data to the FIFO
        @(posedge clk);
        noc_in = 32'hA5A5_A5A5;
        noc_ivalid = 1;
        @(posedge clk);
        if (noc_oready) begin
            $display("Data accepted: 0x%h", noc_in);
        end else begin
            $display("ERROR: FIFO did not accept data");
        end
        
        // Write another data word
        noc_in = 32'h5A5A_5A5A;
        @(posedge clk);
        if (noc_oready) begin
            $display("Data accepted: 0x%h", noc_in);
        end else begin
            $display("ERROR: FIFO did not accept data");
        end
        
        // Stop writing
        noc_ivalid = 0;
        
        // Wait a few cycles for data to propagate through to output
        repeat(2) @(posedge clk);
        $display("Data at output: 0x%h", out);
        @(posedge clk); // Wait one more cycle
        
        // Check the next data value after another cycle
        $display("Next data value at output: 0x%h", out);
        
        // Test Case 2: FIFO overflow test
        $display("\nTest Case 2: FIFO overflow test");
        
        // Fill the FIFO
        for (int i = 0; i < INPUT_BUFFER_DEPTH + 1; i++) begin
            @(posedge clk);
            noc_in = 32'h1000_0000 + i;
            noc_ivalid = 1;
            
            if (noc_oready) begin
                $display("Data %0d accepted: 0x%h", i, noc_in);
            end else begin
                $display("Data %0d not accepted (FIFO full): 0x%h", i, noc_in);
                break;
            end
        end
        
        // Stop writing
        noc_ivalid = 0;
        
        // Test Case 3: Reset during operation
        $display("\nTest Case 3: Reset during operation");
        
        // Wait for some cycles
        #(CLK_PERIOD*2);
        
        // Assert reset
        rst_n = 0;
        #(CLK_PERIOD*2);
        $display("Reset asserted for %0d clock cycles", 2);
        
        // Release reset and try new operations
        rst_n = 1;
        #(CLK_PERIOD*2);
        
        // Write new data
        @(posedge clk);
        noc_in = 32'hDEAD_BEEF;
        noc_ivalid = 1;
        @(posedge clk);
        noc_ivalid = 0;
        
        // Wait a few cycles to observe output
        repeat(3) @(posedge clk);
        $display("After reset, data at output: 0x%h", out);
        
        // End simulation
        #(CLK_PERIOD*5);
        $display("\nTest completed successfully");
        $finish;
    end
    
    // Dump waveforms
    initial begin
        $dumpfile("ucore_input_channels_tb.vcd");
        $dumpvars(0, ucore_input_channels_tb);
    end

endmodule