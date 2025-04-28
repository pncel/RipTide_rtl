// Keith Phou

// RipTide Generic Processing Element (PE)
// Based on the paper: "RipTide: A programmable, energy-minimal dataflow compiler and architecture"
// This module combines the μcore with a functional unit to create a complete PE

module pe_ucore #(
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