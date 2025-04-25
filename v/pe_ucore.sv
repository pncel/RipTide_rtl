// Keith Phou

// RipTide Generic Processing Element (PE)
// Based on the paper: "RipTide: A programmable, energy-minimal dataflow compiler and architecture"
// This module combines the μcore with a functional unit to create a complete PE

module pe_ucore #(
    parameter DATA_WIDTH = 32,
    parameter FU_TYPE = 0,                      // 0: Arithmetic, 1: Multiplier, 2: Memory, 3: Control Flow, 4: Stream
) (
    input  logic clk,                           // 
    input  logic rst_n,                         // 

    // ucore signals
    input  logic ctrl_en,                       // Control enable
    input  logic ctrl_clear,                    // Control clear
    output logic ctrl_done                      // Control done

    // NoC interface
    input  logic [] noc_ivalid,                 // Input valid signals from NoC
    input  logic [] noc_in,                     // Input data from NoC
    output logic [] noc_oready,                 // Ready signals to NoC

    output logic [] noc_out,                    // Output data to NoC
    output logic [] noc_valid,                  // Output valid signals to NoC
    input  logic [] noc_ready,                  // Ready signals from NoC

    // Configuration interface
    input  logic cfg_en,                        // Configuration enable
    input  logic [] cfg_in,                     // Configuration data input
    output logic [] cfg_out,                    // Configuration data output (for daisy-chaining) 
    
);

endmodule
