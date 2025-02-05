module DIV(
    
    input [31:0] Q,
    input [31:0] M,
    input clk,
	 
    output [31:0] quotient,
    output [31:0] remainder

);
    reg [31:0] A;
    reg [31:0] Q_reg;
    integer count;

    initial begin

        A = 32'b0;
        count = 0;
        Q_reg = Q;

    end

	always @(posedge clk) begin

        if (count < 31) begin

            // Check the sign bit, then shift
            if (A[0] == 0) begin

                Q_reg = Q_reg << 1;
                A = A << 1;

                A = A - M;

            end else begin

                Q_reg = Q_reg << 1;
                A = A << 1;

                A = A + M;
					 
				end

            // Check the sign bit again after shifting
            if (A[0] == 0) begin

                Q_reg[0] = 1;

            end else begin

                Q_reg[0] = 0;

            end

            count = count + 1;
					 
        end else begin

            if (A[0] == 1)

                A = A - M;
					 
					 count = 0;
 
        end

    end	
	
	
   // Quartus yells at me when these are in the always block :(
   assign quotient = Q_reg;
   assign remainder = A;	

endmodule

module DIV_tb;

    // Declare inputs as reg type
    reg [31:0] Q;
    reg [31:0] M;
    reg clk;

    // Declare outputs as wire type
    wire [31:0] quotient;
    wire [31:0] remainder;

    // Instantiate the DIV module
    DIV uut (
        .Q(Q),
        .M(M),
        .clk(clk),
        .quotient(quotient),
        .remainder(remainder)
    );

    // Clock generation
    always begin
        #5 clk = ~clk; // Toggle clk every 5 time units (for a period of 10)
    end

    // Test case procedure
    initial begin
        // Initialize inputs
        clk = 0;
        Q = 32'd50;  // Example dividend
        M = 32'd7;   // Example divisor

        // Monitor outputs
        $monitor("Time = %0d, Q = %d, M = %d, Quotient = %d, Remainder = %d", $time, Q, M, quotient, remainder);

        // Apply reset
        #5;  // Wait for a couple of clock cycles
        Q = 32'd50;  // Set Q to a new value
        M = 32'd7;   // Set M to a new value
        #320;  // Wait some time to see the results

        // Apply another test case
        Q = 32'd100;
        M = 32'd6;
        #320;

        Q = 32'd11;
        M = 32'd3;
        #320;

        // Finish the simulation
        $stop;
    end

endmodule




	
		
		
	
    


   

    

    

    
