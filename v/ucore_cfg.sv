// Keith Phou

// RipTide ucore cfg + constraints
// Based on the paper: "RipTide: A programmable, energy-minimal dataflow compiler and architecture"
// This module is a part of the ucore

module cfg_module #(
    parameter DATA_WIDTH = 32,
    parameter CFG_WIDTH = 64,   // Configuration width - adjust as needed
    parameter CONST_COUNT = 4   // Number of constants stored in the module, 
)(
    // Clock and reset
    input  logic                  clk,
    input  logic                  reset,
    
    // Configuration chain interface
    input  logic                  cfg_en,      // Enable configuration updates
    input  logic [CFG_WIDTH-1:0]  cfg_in,      // Configuration data input
    output logic [CFG_WIDTH-1:0]  cfg_out,     // Configuration data output (for chaining)
    
    // Interface to Functional Unit (FU)
    output logic [DATA_WIDTH-1:0] constants[CONST_COUNT],  // Constants for computation will get muxed
    output logic [7:0]            cfgd,        // Configuration ID/opcode for the FU
    output logic                  cfg          // Configuration valid/active
);

    // Configuration cache, two entries as mentioned in the paper, add parameter for this 
    localparam CONFIG_CACHE_SIZE = 2;

    // Configuration format
    // Discuss with Jovan, temp idea for how we would do config data
    // for now assuming format: [63:62] = cache entry, [61:54] = opcode, [53:0] = constants
    // 

    // Send constant data out
    // send config data into the FU

    // Configuration registers (cache)
    logic [CFG_WIDTH-1:0] config_cache[CONFIG_CACHE_SIZE];
    logic [$clog2(CONFIG_CACHE_SIZE)-1:0] active_config; // Index of active configuration
    
    // Configuration loading logic
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset state
            for (int i = 0; i < CONFIG_CACHE_SIZE; i++)
                config_cache[i] <= '0;
            active_config <= 0;
            cfg <= 0;
        end else if (cfg_en) begin
            // Parse the configuration input
            
            // Store in the specified cache entry
            logic [1:0] cache_entry = cfg_in[63:62];
            config_cache[cache_entry] <= cfg_in;
            
            active_config <= cache_entry;
        end
    end
    
    // Output the active configuration to the FU
    always_comb begin
        if (cfg) begin
            // Extract opcode
            cfgd = config_cache[active_config][61:54];
            
            // Extract constants - assuming they're packed in the lower bits
            // change depending how we are formating the cfg data
            for (int i = 0; i < CONST_COUNT; i++) begin
                constants[i] = config_cache[active_config][(i+1)*DATA_WIDTH-1:i*DATA_WIDTH];
            end
        end else begin
            cfgd = '0;
            for (int i = 0; i < CONST_COUNT; i++) begin
                constants[i] = '0;
            end
        end
    end

endmodule