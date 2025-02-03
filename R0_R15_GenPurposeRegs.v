//16 General purpose registers for 32-bit MINI SRC
//Using a 16x32 reg_file for storage
/*
Control Signals:
write: 	r0in .. r15in 
read:		r0out .. r15out
clear:	RegClr
*/

module R0_R15_GenPurposeRegs #(parameter ClrVal = 32'b0)(
	input clk, reg_clear,
	input [31:0] BusMuxOut,
	input [15:0] GRin,
	input	[15:0] GRoutA,
			
	output [31:0] BusMuxIn,
	output [31:0] BusMuxIn2
	);
	
wire [3:0]w_addr; 
wire [3:0]r_addrA;
wire [3:0]r_addrB;
wire [31:0]w_data;
wire enable;


//Encode 16 r..in signals to w_addr

assign w_addr[0] = GRin[1] | GRin[3] | GRin[5] | GRin[7] | GRin[9] | GRin[11] | GRin[13] | GRin[15];
assign w_addr[1] = GRin[2] | GRin[3] | GRin[6] | GRin[7] | GRin[10] | GRin[11] | GRin[14] | GRin[15];
assign w_addr[2] = GRin[4] | GRin[5] | GRin[6] | GRin[7] | GRin[12] | GRin[13] | GRin[14] | GRin[15];
assign w_addr[3] = GRin[8] | GRin[9] | GRin[10] | GRin[11] | GRin[12] | GRin[13] | GRin[14] |GRin[15];

//Encode 16 r..out signals to r_addr

assign r_addrA[0] = GRoutA[1] | GRoutA[3] | GRoutA[5] | GRoutA[7] | GRoutA[9] | GRoutA[11] | GRoutA[13] | GRoutA[15];
assign r_addrA[1] = GRoutA[2] | GRoutA[3] | GRoutA[6] | GRoutA[7] | GRoutA[10] | GRoutA[11] | GRoutA[14] | GRoutA[15];
assign r_addrA[2] = GRoutA[4] | GRoutA[5] | GRoutA[6] | GRoutA[7] | GRoutA[12] | GRoutA[13] | GRoutA[14] | GRoutA[15];
assign r_addrA[3] = GRoutA[8] | GRoutA[9] | GRoutA[10] | GRoutA[11] | GRoutA[12] | GRoutA[13] | GRoutA[14] |GRoutA[15];

assign r_addrB = r_addrA;

//Mux BusMuxOut with default value for clear

assign w_data = reg_clear ? ClrVal : BusMuxOut;

//Enable logic: clear or any r..in signal
//Using Reduction or to check if any value in encoded signal w_addr is 1

assign enable = reg_clear | GRin[0] | (|w_addr);

//16x32reg_file Module
reg_file RF(clk, enable, r_addrA, r_addrB, w_addr, w_data, BusMuxIn, BusMuxIn2);


endmodule
