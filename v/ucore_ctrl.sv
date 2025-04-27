// Bernardo Lin

// RipTide ucore_control block
// Based on paper: "RipTide: A programmable, energy-minimal dataflow compiler and architecture"
// This module is a part of the ucore
// Currently setting the states so that when it's done, it'll stay at done, will change afterwards

module(ctrl_en, ctrl_clear, ctrl_done, fu_done, clear);
    input logic ctrl_en, ctrl_clear, fu_done;
    output logic ctrl_done, clear;
    enum logic [1:0] { clear, working, done } ps, ns;

    always_comb begin
		case (ps)
			clear:
                ns = working;
            working:
                if(ctrl_clear)
                    ns = clear;
                else if (fu_done)
                    ns = done;
                else
                    ns = working;
            done:
                if(ctrl_clear)
                    ns = clear;
                else if(fu_done)
                    ns = done;
                else
                    ns = done;
            
        endcase
    end

    always_comb begin
		case (ps)
			clear: 
				clear = 1;
                ctrl_done = 0;
                fu_done = 0;
			working: 
				clear = 0;
                fu_done = 0;
                ctrl_done = 0;
			done:
                fu_done = 0;
				ctrl_done = 1;
                clear = 0;
		endcase
	end

    //DFF
    always_ff @(posedge clk) begin
		if (ctrl_clear)
			ps <= clear;
		else
			ps <= ns;
	end
endmodule