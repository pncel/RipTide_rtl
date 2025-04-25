// Keith Phou

// RipTide Top Module
// Based on paper: "RipTide: A programmable, energy-minimal dataflow compiler and architecture"

module riptide_top #(
    parameter ROWS = 6,              // 6x6 fabric as described in the paper
    parameter COLS = 6,
    parameter DATA_WIDTH = 32,       // 32-bit datapath? come back check
    parameter ADDR_WIDTH = 32,
    parameter MEM_SIZE = 32 * 1024 * 8  // 256KB (8x32KB banks) SRAM main memory (VI. RIPTIDE MICROARCHITECTURE)
) (

);

endmodule