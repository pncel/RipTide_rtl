// Keith Phou

// RipTide ucore input channels
// Based on the paper: "RipTide: A programmable, energy-minimal dataflow compiler and architecture"
// This module is a part of the ucore
// 

module ucore_input_channels #(
    parameter DATA_WIDTH = 32,
    parameter NUM_INPUTS = 2                                    // Number of input channels
    ) (

    // Input channel
    input  logic noc_ivalid,                                    // Input valid signals from NoC
    input  logic [DATA_WIDTH-1:0] noc_in,                       // Input data from NoC
    output logic noc_oready,                                    // Ready signals to NoC
    output logic [DATA_WIDTH-1:0] out                           // Need to find name for the output
);


endmodule