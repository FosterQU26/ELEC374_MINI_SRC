
// 32-bit adder with 2 adder_16b instances. This module represents the top-level entity used in the ALU for the ADD and SUB operations.

module adder_32b (
	input cin, // carry-in (used for subtraction)
	input [31:0] x, y, // Summands
	output cout, // carry-out (not used in ALU due to fixed register size in reg_file)
	output [31:0] s // Result (wire)
	);
			
	// carry-in signal for each 16-bit sub-adder. We use 'h' to denote a 'hierarchical' carry.
	wire [2:0] hc;
	assign hc[0] = cin;

	// 'hierachical' Generate and Propagate signals.
	wire [1:0] hP, hG;

	// 2 adder_16b instances, each for a given 16-bit subset of x and y.
	genvar i;
	generate
	for (i=0; i<2; i = i+1) begin : subadders	
		adder_16b subadder (hc[i], x[16*i+15: 16*i], y[16*i+15: 16*i], hP[i], hG[i], s[16*i+15: 16*i]);
	end
	endgenerate

	// Hierarchical carries according to the lookahead framework.
	assign hc[1] = hG[0] | hP[0] & cin;
	assign hc[2] = hG[1] | hP[1] & hG[0] | hP[1] & hP[0] & cin;
	assign cout = hc[2];
	
endmodule

//---------------Testbench---------------//

module adder_32b_testbench();
	
	reg cin;
	reg [31:0] x, y;
	wire cout;
	wire [31:0] s;

	// Design under test.
	adder_32b dut (cin, x, y, cout, s);

	// 6 edge-cases are validated for testbench concision.
	initial begin
		// Test 1: Small positive values
		cin = 0; x = 32'b00000000000000000000000000000101; y = 32'b00000000000000000000000000001011; #10;
		$display("Test 1: cin = %b, x = %b, y = %b, s = %b, cout = %b", cin, x, y, s, cout);
		
		// Test 2: Mixed range values
		cin = 0; x = 32'b00000000111111110000000011111111; y = 32'b00000011111100001111111100001111; #10;
		$display("Test 2: cin = %b, x = %b, y = %b, s = %b, cout = %b", cin, x, y, s, cout);

		// Test 3: Maximum 32-bit values (check carry-out well handled)
		cin = 0; x = 32'b11111111111111111111111111111111; y = 32'b11111111111111111111111111111111; #10;
		$display("Test 3: cin = %b, x = %b, y = %b, s = %b, cout = %b", cin, x, y, s, cout);

		// Test 4: Carry-in enabled (check that all only two bits are high)
		cin = 1; x = 32'b00000000000000001111111111111111; y = 32'b00000000000000000000000000000001; #10;
		$display("Test 4: cin = %b, x = %b, y = %b, s = %b, cout = %b", cin, x, y, s, cout);

		// Test 5: Large values, no carry-out
		cin = 0; x = 32'b11110000111100001111000011110000; y = 32'b00001111000011110000111100001111; #10;
		$display("Test 5: cin = %b, x = %b, y = %b, s = %b, cout = %b", cin, x, y, s, cout);

		// Test 6: zero inputs
		cin = 0; x = 32'b0; y = 32'b0; #10;
		$display("Test 6: cin = %b, x = %b, y = %b, s = %b, cout = %b", cin, x, y, s, cout);

		$stop;
	end
endmodule
