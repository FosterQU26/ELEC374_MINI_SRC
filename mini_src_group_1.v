
module mini_src_group_1 (
	input clk, reset, stop,
	input [31:0] INPORTin,
	output [31:0] OUTPORTout,
	output run
	);
	
	// Program Execution Control
	wire clr, CONin, CON, RAM_wr;
	wire [31:27] IRop;
	
	// General Purpose Register Control
	wire Gra, Grb, Grc, Rin, Rout, BAout;
	
	// Datapath Register Control
	wire [15:0] DPin, DPout;
	
	// ALU Control
	
	wire [15:0] ALUopp;
	
	
	DataPath DP (clk, clr, CONin, Gra, Grb, Grc, Rin, Rout, BAout, RAM_wr, DPin, DPout, ALUopp, INPORTin, OUTPORTout, IRop, CON);

	Control ctrl (reset, stop, clk, CON, IRop, clr, CONin, RAM_wr, Gra, Grb, Grc, Rin, Rout, BAout, DPin, DPout, ALUopp, run);
	
	
endmodule

module tl_testbench();
	reg clk, reset, stop;
	reg [31:0] INPORTin;
	wire [31:0] OUTPORTout;
	wire run;
	
	mini_src_group_1 uut (clk, reset, stop, INPORTin, OUTPUTout, run);
	
	initial begin
		clk <= 0;
		forever #5 clk <= ~clk;
	end
	
	initial begin
		reset <= 1;
		@(posedge clk);
		@(posedge clk);
		
		reset <= 0;
		repeat (4200) @(posedge clk);
	
	end

endmodule
