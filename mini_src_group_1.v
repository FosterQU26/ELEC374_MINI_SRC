
module mini_src_group_1 (
	input CLOCK_50, 
	input [1:0] KEY,
	input [7:0] SW,
	output [6:0] HEX0, HEX1,
	output LEDR5
	);
	
	// Program Execution Control
	wire clr, CONin, CON, RAM_wr, reset, stop;
	wire [31:0] INPORTin = {24'b0, SW};
	wire [31:0] OUTPORTout;
	wire [31:27] IRop;

	//Sanitize Inputs
	input_sanitizer sanitized_reset (CLOCK_50, 1'b0, ~KEY[0], reset);
   input_sanitizer sanitized_stop (CLOCK_50, 1'b0, ~KEY[1], stop);

	//Hex Modules
	hex_to_7 out3_0 (OUTPORTout[3:0], HEX0);
	hex_to_7 out7_4 (OUTPORTout[7:4], HEX1);
	
	// General Purpose Register Control
	wire Gra, Grb, Grc, Rin, Rout, BAout;
	
	// Datapath Register Control
	wire [15:0] DPin, DPout;
	
	// ALU Control
	wire [15:0] ALUopp;
	
	DataPath DP (CLOCK_50, clr, CONin, Gra, Grb, Grc, Rin, Rout, BAout, RAM_wr, DPin, DPout, ALUopp, INPORTin, OUTPORTout, IRop, CON);

	Control ctrl (reset, stop, CLOCK_50, CON, IRop, clr, CONin, RAM_wr, Gra, Grb, Grc, Rin, Rout, BAout, DPin, DPout, ALUopp, LEDR5);
	
endmodule

`timescale 1ns/1ps

module tl_testbench();
	reg CLOCK_50;
	reg [1:0] KEY;
	reg [7:0] SW;
	wire [6:0] HEX0, HEX1;
	wire [5:0] LEDR;
	
	mini_src_group_1 uut (CLOCK_50, KEY, SW, HEX0, HEX1, LEDR);
	
	initial begin
		CLOCK_50 <= 0;
		forever #5 CLOCK_50 <= ~CLOCK_50;
	end
	
	initial begin
		SW <= 8'hC0;
		KEY[1] <= 1;
		KEY[0] <= 1;
		
		repeat(10) @(posedge CLOCK_50);
		
		KEY[0] <= 0;
		
		repeat(10) @(posedge CLOCK_50);
		
		KEY[0] <= 1;
		
		while(1) begin
			@(posedge CLOCK_50);
			if(!LEDR[5]) $stop;
		end
		
	end
	
endmodule
