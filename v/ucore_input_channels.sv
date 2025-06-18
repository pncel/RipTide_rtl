// Keith Phou

// RipTide ucore input channels
// Based on the paper: "RipTide: A programmable, energy-minimal dataflow compiler and architecture"
// This module is a part of the ucore
module ucore_input_channels #(
    parameter DATA_WIDTH = 32,
    parameter N = 2,                                           // Number of input channels?
    parameter INPUT_BUFFER_DEPTH = 2                           // Depth of input channel buffer
    ) (
    input  logic clk,
    input  logic rst_n,

    // Input channel
    input  logic noc_ivalid,                                    // Input valid signals from NoC
    input  logic [DATA_WIDTH-1:0] noc_in,                       // Input data from NoC
    input  logic 
    output logic noc_oready,                                    // Ready signals to NoC
    logic noc_ovalid,                                          // Valid signal for output data
    output logic [DATA_WIDTH-1:0] out                           // Need to find name for the output
);

    // FIFO Signals
    logic fifo_yumi;          // Dequeue signal for FIFO
    logic fifo_reset;         // Reset signal for FIFO
    
    // Set reset for FIFO (active high)
    assign fifo_reset = ~rst_n;
    
    // Instantiate the FIFO
    bsg_fifo_1r1w_small_hardened #(
        .width_p(DATA_WIDTH),
        .els_p(INPUT_BUFFER_DEPTH),
        .ready_THEN_valid_p(0)  // Using valid-and-ready protocol
    ) input_fifo (
        .clk_i(clk),
        .reset_i(fifo_reset),
        
        // Write side (from NoC)
        .v_i(noc_ivalid),
        .ready_param_o(noc_oready),     // ready signal to sender (upstream)
        .data_i(noc_in),
        
        // Read side (to output)
        .v_o(noc_ovalid),                // valid signal to recevier (downstream)
        .data_o(out),
        .yumi_i(fifo_yumi)
    );


endmodule