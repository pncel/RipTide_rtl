// Keith Phou

// RipTide PE Functional Unit 
// Based on paper: "RipTide: A programmable, energy-minimal dataflow compiler and architecture"
// This module provides the core computational functionality for PEs

module pe_fu #(
    parameter DATA_WIDTH = 32,
    ) (
    input  logic clk,                           // 
    input  logic rst_n,                         // 
    
    // FU interface signals
    output logic fu_done,                       // 
    input  logic clear,                         //  
    input  logic in_valid,                      // Input valid
    input  logic [DATA_WIDTH-1:0] in,           // Input data
    output logic fu_ready,                      // FU ready for inputs
    
    input  logic cfgd,                          // Configuration done? wht does d stand for
    input  logic [DATA_WIDTH-1:0] cfg,          // Configuration data
    
    input  logic out_ready,                     // Downstream ready
    output logic [DATA_WIDTH-1:0] fu_out,       // Output data
    output logic fu_alloc,                      // Reserve space in output channel
    output logic fu_valid,                      // Result is valid
);

endmodule
