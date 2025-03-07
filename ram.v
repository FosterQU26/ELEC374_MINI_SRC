/*
	Modular 2^depth x width memory array with 1 read port and 1 write port.
	Read port accesses r_data according to address r_addr asynchronously.
	The single write port writes w_data to address w_addr synchronously.
*/


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
	
	
	// DESIGN LIMITATION: an absolute path is required to read the contents of ram.txt, which needs to be changed based on the device.
	initial $readmemh("C:/Users/foste/Documents/3rd_Year_24-25/ELEC374/ELEC374_MINI_SRC/ram.txt", memory_array);
	
	// r_data is immediately available as r_addr is presented to the RF (asynchronous)
	assign r_data = memory_array[r_addr];
	
	// Data writes are synchronous to clk with wr_en high.
	always @(posedge clk) begin
		if (wr_en) memory_array[w_addr] <= w_data; 
	end
	
endmodule
