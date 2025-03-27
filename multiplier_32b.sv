/*
	multiplier_32b is a 32-bit multiplier leveraging both optimization structures: bit-pair recoding and carry-save addition.
	It accepts M and Q as the multiplication and multiplier, respectively.
*/


module multiplier_32b (
	input [31:0] M, Q,
	output [63:0] result
	);
	
	// All relevant variations of M for booth augend selection.
	wire [32:0] Q_shifted = {Q, 1'b0}; // Left shifted Q by 1 such that the i-1 Booth check is valid with i = 0.
	wire [31:0] negM = -M;
	wire [32:0] Mx2 = {M, 1'b0};
	wire [32:0] negMx2 = {negM, 1'b0};
	
	// Augends.
	reg [63:0] partial_products [15:0];
	
	integer i;
	// Perform Booth Augend Selection
	always @(*) begin
		for (i = 0; i < 31; i = i+2) begin
			// Choose variant of M based on partial_products
			case ({Q_shifted[i+2], Q_shifted[i+1], Q_shifted[i]})

				// All values are properly sign-extended.
				3'b000: partial_products[i>>1] = 64'b0; // 0 x M
				3'b001: partial_products[i>>1] = {{32{M[31]}}, M}; // +1 x M
				3'b010: partial_products[i>>1] = {{32{M[31]}}, M}; // +1 x M 
				3'b011: partial_products[i>>1] = {{31{Mx2[32]}}, Mx2}; // +2 x M
				3'b100: partial_products[i>>1] = {{31{negMx2[32]}}, negMx2}; // -2 x M
				3'b101: partial_products[i>>1] = {{32{negM[31]}}, negM}; // -1 x M
				3'b110: partial_products[i>>1] = {{32{negM[31]}}, negM}; // -1 x M
				3'b111: partial_products[i>>1] = 64'b0; // 0 x M
				default: partial_products[i>>1] = 64'b0;
			endcase
			// Apply appropriate shift before addition.
			partial_products[i>>1] = partial_products[i>>1] << i;
		end
	end
	
	// Final operands after reduction process
	wire [63:0] reduced1, reduced2;
	
	// 16-to-2 CSA reducer.
	CSA_tree_16to2 reduction (.augends(partial_products), .reduced1(reduced1), .reduced2(reduced2));
	
	// Final carry-propagate stage, with no carry-in, nor carry-out (result for 32-bit mult. is 64-bits)
	adder_64b carry_propagate (.cin(1'b0), .x(reduced1), .y(reduced2), .s(result)); // No cout.
	
endmodule


`timescale 1ns / 1ps

module multiplier_32b_tb;
    reg signed [31:0] M, Q;
    wire signed [63:0] result;
    
    // Instantiate the multiplier
    multiplier_32b dut (M, Q, result);
    
	initial begin
		 run_test(32'd0, 32'd0, 32'd0);                  // 0 * 0 = 0
		 run_test(32'd15, 32'd10, 32'd150);              // 15 * 10 = 150
		 run_test(-32'd15, 32'd10, -32'd150);            // -15 * 10 = -150
		 run_test(32'd15, -32'd10, -32'd150);            // 15 * -10 = -150
		 run_test(-32'd15, -32'd10, 32'd150);            // -15 * -10 = 150
		 run_test(32'h7FFFFFFF, 32'd1, 32'h7FFFFFFF);    // Largest positive * 1
		 run_test(32'h80000000, 32'd1, 32'h80000000);    // Smallest negative * 1
		 run_test(32'hFFFFFFFF, 32'hFFFFFFFF, 32'd1);    // -1 * -1 = 1
		 
		 $display("Testbench completed successfully");

		 $stop;
	end

	task run_test(input signed [31:0] M_in, input signed [31:0] Q_in, input signed [31:0] expected_result);
	begin
		 M = M_in;
		 Q = Q_in;
		 #10; // Wait for computation

		 if (result !== expected_result) begin
			  $display("Test Failed: M=%d, Q=%d -> Expected Result=%d but got Result=%d",
						  M_in, Q_in, expected_result, result);
		 end 
	end
	endtask

endmodule

