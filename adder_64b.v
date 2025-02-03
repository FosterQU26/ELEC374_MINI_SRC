
// 32-bit adder with 2 adder_16b instances.
module adder_64b (
			input cin,
			input [63:0] x, y,
			output cout,
			output [63:0] s
			);
			
	// carry-in signal for each 16-bit sub-adder. We use 'h' to denote a 'hierarchical' carry.
	wire [4:0] hc;
	assign hc[0] = cin;

	// 'hierachical' Generate and Propagate signals.
	wire [3:0] hP, hG;

	// 4 CLA_4b instances for each 4-bit subset of x and y.
	genvar i;
	generate
	for (i=0; i<4; i = i+1) begin : subadders	
		adder_16b subadder (hc[i], x[16*i+15: 16*i], y[16*i+15: 16*i], hP[i], hG[i], s[16*i+15: 16*i]);
	end
	endgenerate

	// Hierarchical carries according to the lookahead framework.
	assign hc[1] = hG[0] | hP[0] & cin;
	assign hc[2] = hG[1] | hP[1] & hG[0] | hP[1] & hP[0] & cin;
	assign hc[3] = hG[2] | hP[2] & hG[1] | hP[2] & hP[1] & hG[0] | hP[2] & hP[1] & hP[0] & cin;
	assign hc[4] = hG[3] | hP[3] & hG[2] | hP[3] & hP[2] & hG[1] | hP[3] & hP[2] & hP[1] & hG[0] | hP[3] & hP[2] & hP[1] & hP[0] & cin;
	assign cout = hc[4];
	
endmodule
