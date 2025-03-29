
/*
	input_sanitizer is an FSM that regulates an input signal by interpreting a constant logic 1 as a single signal pulse, either at the start of end of signal assertion.
	It accepts 1-bit input in, and asserts the single pulse signal out_start when the input goes high, and asserts out_end when the input goes low. 
	The FSM is synchronized to clk with a synch. reset.
*/

module input_sanitizer (
	input clk, reset, in,
	output out
);
	
	// There are two states: OFF (0) and ON (1)
	reg ps, ns;
	
	//Initilize States
	initial begin
		ps = 1'b0;
		ns = 1'b0;
	end
	
	// Next state logic (see state diagram in report)
	always @(*) begin
		case (ps)
			1'b0:	if (in) ns = 1'b1;
				else ns = 1'b0;
			1'b1: 	if (in) ns = 1'b1;
				else ns = 1'b0;
		endcase
	end
	
	// asserting outputs.
	assign out = (ps == 1'b0) & in & ~reset; // When input goes high
	
	// State transitions.
	always @(posedge clk) begin
		if (reset)
			ps <= 1'b0;
		else 
			ps <= ns;
	end
endmodule 


// This testbench verifies that for a sustained assertion of in, out_start pulses for a single clock cycle at the start of the assertion,
// and out_end pulse for a single clock cycle at the end of the assertion.

module input_sanitizer_testbench();
	reg clk, reset, in; 
	wire out;
	
	// Above design under test.
	input_sanitizer dut (clk, reset, in, out);
	
	// Establishing clock behaviour.
	parameter clock_period = 20;
	initial begin
		clk <= 0;
		forever #(clock_period/2) clk <= ~clk;
	end
	
	initial begin
		reset <= 1;	in <= 0;	@(posedge clk)
		reset <= 0;	in <= 1;	@(posedge clk)	
		
		// Hold in high for 10 cycles.
		repeat(10) 
			@(posedge clk);
		
		// Goes low for 10 cycles.
		in <= 0;					@(posedge clk);
		
		repeat(10) 
			@(posedge clk);

		$stop;
	end
endmodule