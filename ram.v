module ram #(
	// for modularity
	parameter depth = 9,
	parameter width = 32
	)(
	input clk, wr_en,
	input [depth-1:0] r_addr, w_addr,
	input [width-1:0] w_data,
	output [width-1:0] r_data
	);
	
	// Internal memory array consisting of 2^depth, width-lengthed registers.
	// This definition enforces a right-to-left increasing bit significance, and an up-to-down addressing scheme.
	reg [width-1:0] memory_array [0:2**depth-1];
	
	initial $readmemh("ram.txt", memory_array);
	
	// r_data1/2 are immediately available as r_addr1/2 is presented to the RF
	// Two read addresses are supported by the register file should we choose to implement a 3-bus design in later phases.
	assign r_data = memory_array[r_addr];
	
	
	// Data writes are synchronous to clk with wr_en high.
	always @(posedge clk) begin
		if (wr_en) memory_array[w_addr] <= w_data; 
	end
	
endmodule
