/*
	conditional_ff_logic assesses whether a branching condition has been met, indicating instruction status to the control unit. 
	It accepts IR[20:19], referring to the Rb segment of the IR containing the branch condition to evaluate.
	The decoded condition is applied to the current contents of the bus: if CONin is high, CON will capt the result of the comparison.
*/


module conditional_ff_logic (
	input [1:0] IR_20_19,
	input [31:0] BusMuxOut, // Out refers to the perspective of the Bus.
	input CONin, clk,
	output reg CON
	);
	
	// Assesses whether the current Bus contents are equal to zero (reduction NOR)
	wire bus_zero = ~| BusMuxOut;
	// Assesses whether the current Bus contents are negative.
	wire bus_neg = BusMuxOut[31];
	
	// Pairing the condition to the bus contents
	wire CON_D;
	assign CON_D = (IR_20_19 == 2'b00) && bus_zero || (IR_20_19 == 2'b01) && !bus_zero 
		|| (IR_20_19 == 2'b10) && !bus_neg || (IR_20_19 == 2'b11) && bus_neg;
	
	// Recording the result of the condition in CON if CONin is high.
	initial CON <= 1'b0;
	always @(posedge clk) if (CONin) CON <= CON_D;

endmodule
	
	
// Testbench	
module con_ff_tb();
	reg [1:0] IR_20_19;
	reg [31:0] BusMuxOut;
	reg CONin, clk;
	wire CON;
	
	// Design Under Test
	conditional_ff_logic DUT (IR_20_19, BusMuxOut, CONin, clk, CON);
	
	// Establishing clock behaviour.
	parameter clock_period = 20;
	initial begin
		clk <= 0;
		forever #(clock_period/2) clk <= ~clk;
	end
	
	initial begin
		// Branch if 0
		IR_20_19 <= 2'b00; BusMuxOut <= 32'b0; CONin <= 1'b0; @(posedge clk) // No impact.
		IR_20_19 <= 2'b00; BusMuxOut <= 32'b0; CONin <= 1'b1; @(posedge clk) // Success
		IR_20_19 <= 2'b00; BusMuxOut <= 32'b1; CONin <= 1'b1; @(posedge clk) // Failure
		
		// Branch if not 0
		IR_20_19 <= 2'b01; BusMuxOut <= 32'b1; CONin <= 1'b1; @(posedge clk) // Success
		IR_20_19 <= 2'b01; BusMuxOut <= 32'b0; CONin <= 1'b1; @(posedge clk) // Failure
		
		// Branch if pos
		IR_20_19 <= 2'b10; BusMuxOut <= 32'b1; CONin <= 1'b1; @(posedge clk) // Success
		IR_20_19 <= 2'b10; BusMuxOut <= 32'hFFFF0000; CONin <= 1'b1; @(posedge clk) // Failure
		
		// Branch if neg
		IR_20_19 <= 2'b11; BusMuxOut <= 32'hFFFF0000; CONin <= 1'b1; @(posedge clk) // Success
		IR_20_19 <= 2'b11; BusMuxOut <= 32'b1; CONin <= 1'b1; @(posedge clk); // Failure
		
		@(posedge clk)
		$stop;
	end
endmodule
