
/*
	R0_R15_GenPurposeRegs is an abstraction layer for reg_file.v, given the control signals required in the project specification.
	It encodes the 16 one-hot-encoded enable and 'read' signals as 4-bit write and read addresses to the register file.
*/

/*
	DESIGN DECISIONS: 
	We chose to *vectorize* the enable and read signals to provide more clarity to our design.
	Therefore, in all instantiations of this module, signals like 'rXin' are grouped as a single vector GRin.
	Similarly, signals like 'rXout' are grouped as a single vector GRout.
	
	PHASE 2 EDIT:
	When BAout is high and the address presented to the module refers to R0, 
	zero is placed on the output data lines rather than the contents of the register.
*/

module R0_R15_GenPurposeRegs #(
	parameter ClrVal = 32'b0
	)(
	input clk, reg_clear, BAout,
	input [31:0] BusMuxOut,
	input [15:0] GRin, // enable vector (One-Hot). IN refers to the perspective of the registers, not the Bus.
	input	[15:0] GRout, // read vector (One-Hot). OUT refers to the perspective of the registers, not the Bus.
			
	output [31:0] BusMuxIn
	);
	
	wire [3:0] w_addr; // Encoded write address
	wire [3:0] r_addr; // Encoded read addresses
	wire [31:0] w_data; // Write data from Bus.
	wire enable;
	wire [31:0] data_out;


	//Encode 16 r..in signals to w_addr

	assign w_addr[0] = GRin[1] | GRin[3] | GRin[5] | GRin[7] | GRin[9] | GRin[11] | GRin[13] | GRin[15];
	assign w_addr[1] = GRin[2] | GRin[3] | GRin[6] | GRin[7] | GRin[10] | GRin[11] | GRin[14] | GRin[15];
	assign w_addr[2] = GRin[4] | GRin[5] | GRin[6] | GRin[7] | GRin[12] | GRin[13] | GRin[14] | GRin[15];
	assign w_addr[3] = GRin[8] | GRin[9] | GRin[10] | GRin[11] | GRin[12] | GRin[13] | GRin[14] |GRin[15];

	//Encode 16 r..out signals to r_addr

	assign r_addr[0] = GRout[1] | GRout[3] | GRout[5] | GRout[7] | GRout[9] | GRout[11] | GRout[13] | GRout[15];
	assign r_addr[1] = GRout[2] | GRout[3] | GRout[6] | GRout[7] | GRout[10] | GRout[11] | GRout[14] | GRout[15];
	assign r_addr[2] = GRout[4] | GRout[5] | GRout[6] | GRout[7] | GRout[12] | GRout[13] | GRout[14] | GRout[15];
	assign r_addr[3] = GRout[8] | GRout[9] | GRout[10] | GRout[11] | GRout[12] | GRout[13] | GRout[14] |GRout[15];

	// Mux BusMuxOut with default value for clear

	assign w_data = reg_clear ? ClrVal : BusMuxOut;

	// Enable logic: clear or any r..in signal
	// Using Reduction or to check if any value in encoded signal w_addr is 1

	assign enable = reg_clear | GRin[0] | (|w_addr);

	// 16x32reg_file Module
	reg_file RF(clk, enable, r_addr, w_addr, w_data, data_out);
	
	assign BusMuxIn = (GRout[0] && BAout) ? 32'b0 : data_out;
	
endmodule


	