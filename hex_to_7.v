/*
	hex_to_7 defines the combinational logic behind the hex-to-7-segment conversion.
	Module takes 4-bit input in and maps it to its associated 7-bit segment out display combination.
*/

module hex_to_7 (
	input [3:0] in,
	output reg [6:0] out
);
	
	// in to out maps.
	always  @(*) begin
		case (in)
			4'b0000: out = 7'b1000000;
			4'b0001: out = 7'b1111001;
			4'b0010: out = 7'b0100100;
			4'b0011: out = 7'b0110000;
			4'b0100: out = 7'b0011001;
			4'b0101: out = 7'b0010010;
			4'b0110: out = 7'b0000010;
			4'b0111: out = 7'b1111000;
			4'b1000: out = 7'b0000000;
			4'b1001: out = 7'b0010000;
			4'b1010: out = 7'b0001000;
			4'b1011: out = 7'b0000011;
			4'b1100: out = 7'b1000110;
			4'b1101: out = 7'b0100001;
			4'b1110: out = 7'b0000110;
			4'b1111: out = 7'b0001110;
			default: out = 7'bX;
		endcase
	end
endmodule

// hex_to_7_testbench: Check that every possible input (4'h0 to 4'hF) is properly outputted by hex_to_7.
module hex_to_7_testbench();
	
	reg [3:0] in;
	wire [6:0] out;
	
	hex_to_7 dut (in, out);
	
	// Loop from 4'h0 to 4'hF and assign in to loop variable. 
	integer i;
	initial begin
		for (i = 0; i < 2**4; i=i+1) begin
			in = i; #50;
		end
	end
endmodule