/*
	register.v is the modular register entity used as a template for all internal Datapath registers,
	including PC, IR, Z, Y, MAR, MDR, HI, LO.
	
	Clarification: BusMuxOut refers to the data fed to the *input* of the register, 
	while BusMuxIn regers to the data *outputted* by the register. 
	In/Out therefore refers to I/O from the Bus' perspective.
*/

module register #(
		parameter DATA_WIDTH_IN = 32, DATA_WIDTH_OUT = 32, INIT = 32'b0
		)(
		input clear, clock, enable,
		input	[DATA_WIDTH_IN-1:0] BusMuxOut,
		output wire [DATA_WIDTH_OUT-1:0] BusMuxIn
	);

	// Internal synchronous register.
	reg [DATA_WIDTH_IN-1:0] q;

	// Initialize Q with default value.
	initial q = INIT;

	always @ (posedge clock) begin
		if (clear)
			q <= {DATA_WIDTH_IN{1'b0}};
		else if (enable)
			q <= BusMuxOut;
	end

	assign BusMuxIn = q[DATA_WIDTH_OUT-1:0];

endmodule

