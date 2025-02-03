/*-------------------Top-Level-------------------*/

// 16-bit adder with 4 CLA_4b instances.
module adder_16b (
	input cin,
	input [15:0] x, y,
	output Ppp, Gpp, // 2nd order propagate/generate
	output [15:0] s
	);
			
	// carry signal for each 4-bit sub-adder. We use 'h' to denote a 'hierarchical' carry.
	wire [3:0] hc;
	assign hc[0] = cin;

	// 'hierachical' Generate and Propagate signals.
	wire [3:0] hP, hG;

	// 4 CLA_4b instances for each 4-bit subset of x and y.
	genvar i;
	generate
	for (i=0; i<4; i = i+1) begin : subadders	
		CLA_4b subadder (hc[i], x[4*i+3: 4*i], y[4*i+3: 4*i], hP[i], hG[i], s[4*i+3: 4*i]);
	end
	endgenerate

	// Hierarchical carries according to the lookahead framework.
	assign hc[1] = hG[0] | hP[0] & cin;
	assign hc[2] = hG[1] | hP[1] & hG[0] | hP[1] & hP[0] & cin;
	assign hc[3] = hG[2] | hP[2] & hG[1] | hP[2] & hP[1] & hG[0] | hP[2] & hP[1] & hP[0] & cin;
	// hc[4] not necessary since adder_16b is itself a subadder.
	
	assign Ppp = hP[3] & hP[2] & hP[1] & hP[0];
	assign Gpp = hG[3] | hP[3] & hG[2] | hP[3] & hP[2] & hG[1] | hP[3] & hP[2] & hP[1] & hG[0];
	
endmodule

/*-------------------Mid-Level-------------------*/
	
// 4-bit Carry-Lookahead block
module CLA_4b (
	input cin,
	input [3:0] x, y,
	output Pp, Gp,
	output [3:0] s
	);
	
	// Carry signal for each bit stage
	wire [4:0] c;
	assign c[0] = cin;
	
	// Generate and Propagate signals for each bit stage
	wire [3:0] P, G;

	// bcell instances for each bit stage.
	genvar i;
	generate
	for (i=0; i<4; i = i+1) begin : bcells	
		bcell BC (x[i], y[i], c[i], s[i], P[i], G[i]);
	end
	endgenerate
	
	// Verbose expressions for each carry are required to minimize gate delays.
	// Compare with c[i+1] = G[i] | P[i] & c[i] in RTL viewer.
	assign c[1] = G[0] | P[0] & cin;
	assign c[2] = G[1] | P[1] & G[0] | P[1] & P[0] & cin;
	assign c[3] = G[2] | P[2] & G[1] | P[2] & P[1] & G[0] | P[2] & P[1] & P[0] & cin;

	// The 2nd level CL hierarchy will produce c[4] carries under the 'lookahead' framework - no need to derive internally.
	// using Pp and Gp (P', G') below
	assign Pp = P[3] & P[2] & P[1] & P[0];
	assign Gp = G[3] | P[3] & G[2] | P[3] & P[2] & G[1] | P[3] & P[2] & P[1] & G[0]; 
	
endmodule

/*-------------------Bottom-Level-------------------*/

// Bit cell producing Generate and Propagate signals for each xi, yi, ci tuple as presented in lecture.
module bcell (
	input xi, yi, ci,
	output si, Pi, Gi
	);
	
	assign Pi = xi ^ yi;
	assign si = Pi ^ ci;
	assign Gi = xi & yi;

endmodule


/*-------------------Top-Level Testbench-------------------*/

module adder_16b_testbench();
	
	reg cin;
	reg [15:0] x, y;
	wire Ppp, Gpp;
	wire [15:0] s;

	adder_16b dut (cin, x, y, Ppp, Gpp, s);
	
	initial begin
		// Test 1: Small positive values
		cin = 0; x = 16'b0000_0000_0000_0101; y = 16'b0000_0000_0000_1011; #10;
		$display("Test 1: cin = %b, x = %b, y = %b, s = %b, Ppp = %b, Gpp = %b", cin, x, y, s, Ppp, Gpp);

		// Test 2: Mixed range values
		cin = 0; x = 16'b0000_1000_0000_1111; y = 16'b0001_0111_1100_1100; #10;
		$display("Test 2: cin = %b, x = %b, y = %b, s = %b, Ppp = %b, Gpp = %b", cin, x, y, s, Ppp, Gpp);

		// Test 3: Maximum 16-bit values
		cin = 0; x = 16'b1111_1111_1111_1111; y = 16'b1111_1111_1111_1111; #10;
		$display("Test 3: cin = %b, x = %b, y = %b, s = %b, Ppp = %b, Gpp = %b", cin, x, y, s, Ppp, Gpp);

		$stop;
	end
endmodule
