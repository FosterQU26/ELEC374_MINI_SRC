module Bus (
	input [31:0] R0R15_in, 
	input [31:0] HI_in, 
	input [31:0] LO_in,
	input [31:0] ZHI_in,
	input [31:0] ZLO_in,
	input [31:0] PC_in,
	input [31:0] MDR_in,
	input [31:0] INPORT_in,
	
	input R0R15_out, HI_out, LO_out, ZHI_out, ZLO_out, PC_out, MDR_out, INPORT_out,
	
	output wire [31:0]BusMuxOut
);

reg [31:0]q;

always @ (*) begin
	
	if 		(R0R15_out) 	q = R0R15_in;
	else if 	(HI_out) 		q = HI_in;
	else if 	(LO_out) 		q = LO_in;
	else if 	(ZHI_out) 		q = ZHI_in;
	else if 	(ZLO_out) 		q = ZLO_in;
	else if 	(PC_out) 		q = PC_in;
	else if 	(MDR_out) 		q = MDR_in;
	else if 	(INPORT_out) 	q = INPORT_in;
	else 							q = 32'b0;
	
end

assign BusMuxOut = q;

endmodule
