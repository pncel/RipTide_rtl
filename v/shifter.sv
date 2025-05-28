// Keith Phou

module shifter(
	input logic		[63:0]	value,
	input logic					direction, // 0: left, 1: right
	input	logic		[5:0]		distance,
	output logic	[63:0]	result
	);
	
	always_comb begin
		if (direction == 0)
			result = value << distance;
		else
			result = value >> distance;
	end
endmodule