
module mini_src_group_1 (
	input CLOCK_50, 
	input [1:0] KEY,
	input [7:0] SW,
	output [6:0] HEX0, HEX1,
	output [5:5] LEDR
	);
	
	// Program Execution Control
	wire clr, CONin, CON, RAM_wr, reset, stop;
	wire [31:0] INPORTin = {24'b0, SW};
	wire [31:0] OUTPORTout;
	wire [31:27] IRop;
	
	input_sanitizer sanitized_reset (CLOCK_50, 1'b0, ~KEY[0], reset);
	input_sanitizer sanitized_stop (CLOCK_50, 1'b0, ~KEY[1], stop);
	hex_to_7 out3_0 (OUTPORTout[3:0], HEX0);
	hex_to_7 out7_4 (OUTPORTout[7:4], HEX1);
	
	// General Purpose Register Control
	wire Gra, Grb, Grc, Rin, Rout, BAout;
	
	// Datapath Register Control
	wire [15:0] DPin, DPout;
	
	// ALU Control
	wire [15:0] ALUopp;
	
	DataPath DP (CLOCK_50, clr, CONin, Gra, Grb, Grc, Rin, Rout, BAout, RAM_wr, DPin, DPout, ALUopp, INPORTin, OUTPORTout, IRop, CON);

	Control ctrl (reset, stop, CLOCK_50, CON, IRop, clr, CONin, RAM_wr, Gra, Grb, Grc, Rin, Rout, BAout, DPin, DPout, ALUopp, LEDR[5]);
	
endmodule

`timescale 1ns/1ps

module tl_testbench();
	reg clk, reset, stop;
	reg [31:0] INPORTin;
	wire [31:0] OUTPORTout;
	wire run;
	
	mini_src_group_1 uut (clk, reset, stop, INPORTin, OUTPORTout, run);
	
	initial begin
		clk <= 0;
		forever #5 clk <= ~clk;
	end
	
	initial begin
		reset <= 1;
		@(posedge clk);
		@(posedge clk);
		
		reset <= 0;
		
		while(1) begin
			@(posedge clk);
			if(!run) $stop;
		end
		
	end
	
endmodule
