/*
	DataPath.v stands as the top-level module, instantiating all registers and the ALU.
	For Phase 1 purposes, all control signals are *simulated* to validate the correctness of datapath operations.
*/

`timescale 1ns / 1ps

/*
	DESIGN DECISION:
	Our group decided to incorporate as much vectorization as possible, given the sparsity of control signals such as:
	register enables, register 'reads', and ALU operation IDs. This allows for far cleaner and legible description, 
	without loss of convenience associated to referencing registers by name.
	
	All register and operation IDs are associated their own indices. This is achieved with the following const. definitions.
	
	Enable signals for general purpose registers (like 'rXin') are grouped under GRin (One-Hot-Encoded).
	Enable signals for datapath registers (like 'PCin', 'IRin', 'MARin', 'MDRin', etc.) are grouped under DPin (One-Hot-Encoded).
	Read signals for general purpose registers (like 'rXout') are grouped under GRout (One-Hot-Encoded).
	Read signals for datapath registers (like 'PCout', 'IRout', 'MARout', 'MDRout', etc.) are grouped under DPout (One-Hot-Encoded).
	ALU control signals (like 'add', 'sub', etc.) are grouped under ALUopp (One-Hot-Encoded).
*/


`define PC 0
`define IR 1
`define Y 2
`define MAR 3
`define MDR 4
`define INPORT 5
`define OUTPORT 6
`define Z	7 //Z used for Enable
`define ZHI 8 //ZHI / ZLO used for outputs
`define ZLO 9
`define HI 10
`define LO 11
`define READ 12

`define ADD 0
`define SUB 1
`define NEG 2
`define MUL 3
`define DIV 4
`define AND 5
`define OR  6
`define ROR 7
`define ROL 8
`define SLL 9
`define SRA 10
`define SRL 11
`define NOT 12
`define INC 13

module DataPath (
	/*******Control Signals******/
	input clk, clr,
	
	//Register Write Control
	input [15:0] GRin,
	input	[15:0] DPin,
	
	//Register Read Control
	input [15:0] GRout,
	input	[15:0] DPout,
	
	//ALU Control
	input [15:0] ALUopp,
	
	//Input for Disconnected register ends (INPortIn)
	input  [31:0]INPORTin,
	input	 [31:0]Mdatain,
	//Output Disconnected Register ends (IRout, MARout, OUTPORTout)
	output [31:0] IRout, 
	output [31:0] MARout, 
	output [31:0] OUTPORTout,
	output [31:0] BusMuxInMDR
);


	wire [31:0] BusMuxOut;


	wire [31:0] BusMuxInGR; 
	wire [31:0] BusMuxInGR2;
	wire [31:0] BusMuxInPC;
	wire [31:0] BusMuxInINPORT;
	wire [31:0] BusMuxInHI;
	wire [31:0] BusMuxInLO;

	wire [31:0] YtoA;
	wire [63:0] CtoZ;

	wire [63:0] ZtoBusMux;

	wire GR_Read;
	assign GR_Read = |GRout;

	wire [31:0] MDRin;
	assign MDRin = DPin[`READ] ?  Mdatain : BusMuxOut ;

	// General Purpose Register instantiation
	R0_R15_GenPurposeRegs GR(clk, clr, BusMuxOut, GRin, GRout, BusMuxInGR, BusMuxInGR2);
	
	// All Datapath Register instantiations.
	register PC			(clr, clk, DPin[`PC], BusMuxOut, BusMuxInPC);
	register IR			(clr, clk, DPin[`IR], BusMuxOut, IRout);
	register Y			(clr, clk, DPin[`Y], BusMuxOut, YtoA);
	register MAR		(clr, clk, DPin[`MAR], BusMuxOut, MARout);
	register MDR		(clr, clk, DPin[`MDR], MDRin, BusMuxInMDR);		
	register INPORT	(clr, clk, DPin[`INPORT], INPORTin, BusMuxInINPORT);
	register OUTPORT	(clr, clk, DPin[`OUTPORT], BusMuxOut, OUTPORTout);
	register HI			(clr, clk, DPin[`HI], BusMuxOut, BusMuxInHI);
	register LO			(clr, clk, DPin[`LO], BusMuxOut, BusMuxInLO);
	register Z			(clr, clk, DPin[`Z] , CtoZ, ZtoBusMux);
		defparam Z.DATA_WIDTH_IN = 64,
					Z.DATA_WIDTH_OUT = 64;
				
	// Bus	
	Bus DataPathBus 	(BusMuxInGR, BusMuxInHI, BusMuxInLO, ZtoBusMux[63:32], ZtoBusMux[31:0], BusMuxInPC, BusMuxInMDR, BusMuxInINPORT,
							 GR_Read, DPout[`HI], DPout[`LO], DPout[`ZHI], DPout[`ZLO], DPout[`PC], DPout[`MDR], DPout[`INPORT], BusMuxOut );

	// ALU
	ALU DP_ALU 			(YtoA, BusMuxOut, ALUopp, clk, CtoZ);
					
endmodule 



module datapath_tb();
	
	// Control Signals
	reg clk, clr;
	
	// Register Write Control
	reg [15:0] GRin;
	reg [15:0] DPin;
	
	// Register Read Control
	reg [15:0] GRout;
	reg [15:0] DPout;
	
	// ALU Control
	reg [15:0] ALUopp;
	
	// Input for Disconnected register ends (INPortIn)
	reg [31:0] INPORTin;
	reg [31:0] Mdatain;
	// Output Disconnected Register ends (IRout, MARout, OUTPORTout)
	wire [31:0] IRout; 
	wire [31:0] MARout; 
	wire [31:0] OUTPORTout;
	wire [31:0] BusMuxInMDR;

	// Unit Under Test
	DataPath UUT (clk, clr, GRin, DPin, GRout, DPout, ALUopp, INPORTin, Mdatain, IRout, MARout, OUTPORTout, BusMuxInMDR);
	
	// Establishing Clock Behaviour
	parameter clock_period = 20;
	initial begin
		clk <= 0;
		forever #(clock_period/2) clk <= ~clk;
	end
	
	initial begin
		//---------Default Values----------//
		
		// Clear signal
		clr <= 0; 
		// Register Identifiers: GR = General Register, DP = Datapath Register
		GRin <= 16'b0; DPin <= 16'b0; GRout <= 16'b0; DPout <= 16'b0;
		//ALU Control.
		ALUopp <= 16'b0;
		// Memory Data In.
		Mdatain <= 32'b0;
		
		
		@(posedge clk)
		//---------Preset R3----------//
		
		load_reg(4'd2, -{32'd374}); 
		
		//---------Preset R7----------//

		load_reg(4'd6, {32'd10});
	
	
		//---------AND R4, R3, R7---------//
		
		T0 ();
		T1 (32'h81300000);
		T2 ();
		T3 (4'd2);
		T4 (4'd6, `MUL);
		T5 (4'd0, 1'b1); //HILO
		T6 ();
		
		@(posedge clk)
		$stop;
	end
	
	task load_reg (input [3:0] reg_id, input [31:0] value);
		begin
			Mdatain <= value; DPin[`READ] <= 1; DPin[`MDR] <= 1;
		
			@(posedge clk)
			Mdatain <= 32'b0; DPin[`READ] <= 0; DPin[`MDR] <= 0; // Reset from previous cycle
			DPout[`MDR] <= 1; GRin[reg_id] <= 1; 
			
			@(posedge clk)
			DPout[`MDR] <= 0; GRin[reg_id] <= 0;
		end
	endtask
	
	task T0 ();
		begin
			DPout[`PC] <= 1; DPin[`MAR] <= 1; ALUopp[`INC] <= 1; DPin[`Z] <= 1; // MAR <- [PC], PC <- [PC] + 1
			@(posedge clk)
			DPout[`PC] <= 0; DPin[`MAR] <= 0; ALUopp[`INC] <= 0; DPin[`Z] <= 0;
		end
	endtask
	
	task T1 (input [31:0] op_code);
		begin
			DPout[`ZLO] <= 1; DPin[`PC] <= 1; 	// Accept incremented value.
			DPin[`MDR] <= 1; DPin[`READ] <= 1; Mdatain <= op_code; // MDR <- op_code
			
			@(posedge clk)
			DPout[`ZLO] <= 0; DPin[`PC] <= 0; 	
			DPin[`MDR] <= 0; DPin[`READ] <= 0; Mdatain <= 32'b0; 
		end
	endtask
	
	task T2 ();
		begin
			DPout[`MDR] <= 1; DPin[`IR] <= 1; // IR <- [MDR] (op_code)
			
			@(posedge clk)
			DPout[`MDR] <= 0; DPin[`IR] <= 0;
		end
	endtask
	
	task T3 (input [3:0] reg_id);
		begin
			GRout[reg_id] <= 1; DPin[`Y] <= 1; // Y <- [GR[reg_id]]
			
			@(posedge clk)
			GRout[reg_id] <= 0; DPin[`Y] <= 0;
		end
	endtask
	
	task T4 (input [3:0] reg_id, input [3:0] opp);
		begin
			GRout[reg_id] <= 1; ALUopp[opp] <= 1; DPin[`Z] <= 1; // Z <- [Y] opp [GR[reg_id]]
			if (opp == `DIV) begin 
				repeat (34) begin
					@(posedge clk);
				end
			end
			@(posedge clk)
			GRout[reg_id] <= 0; ALUopp[opp] <= 0; DPin[`Z] <= 0;
		end
	endtask
	
	task T5 (input [3:0] reg_id, input HILO);
		begin
			DPout[`ZLO] <= 1; 
			if (HILO)
				DPin[`LO] <= 1;
			else
				GRin[reg_id] <= 1; // GR[reg_id] <- [ZLO]
			
			@(posedge clk)
			DPout[`ZLO] <= 0; GRin[reg_id] <= 0; DPin[`LO] <= 0;
		end
	endtask
	
	task T6 ();
		begin
			DPout[`ZHI] <= 1; DPin[`HI] <= 1;
			
			@(posedge clk)
			DPout[`ZHI] <= 0; DPin[`HI] <= 0;
		end
	endtask
	
	
endmodule
