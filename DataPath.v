//DataPath

//Testing

`timescale 1ns / 1ps

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

R0_R15_GenPurposeRegs GR(	clk, clr, BusMuxOut, GRin, GRout, BusMuxInGR, BusMuxInGR2 );

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
				
Bus DataPathBus 	(BusMuxInGR, BusMuxInHI, BusMuxInLO, ZtoBusMux[63:32], ZtoBusMux[31:0], BusMuxInPC, BusMuxInMDR, BusMuxInINPORT,
						 GR_Read, DPout[`HI], DPout[`LO], DPout[`ZHI], DPout[`ZLO], DPout[`PC], DPout[`MDR], DPout[`INPORT], BusMuxOut );

//ALU
ALU DP_ALU 			(YtoA, BusMuxOut, ALUopp, CtoZ);
					
endmodule 

module DataPathTB ();

	/********Control Signals********/
	reg clk, clr;
	
	reg [15:0] GRin; 
	reg [15:0] GRout;
	reg [15:0] DPin;
	reg [15:0] DPout;
	
	reg [15:0] ALUopp;
	
	// Input and Output Ports
   reg [31:0]  INPORTin;
	reg [31:0]  Mdatain;
   wire [31:0] IRout, MARout, OUTPORTout, MDRout;
	
/* ---------TODO-----------*/	
//Remove this shit	
	
	parameter Default = 4'b0000 , Reg_load1a = 4'b0001, Reg_load1b = 4'b0010, Reg_load2a = 4'b0011,
				Reg_load2b = 4'b0100, Reg_load3a = 4'b0101, Reg_load3b = 4'b0110, T0 = 4'b0111,
				T1 = 4'b1000, T2 = 4'b1001, T3 = 4'b1010, T4 = 4'b1011, T5 = 4'b1100;
	reg [3:0] Present_state = Default;
	
// Fuck that shit ^^^^^^^^^	
	
	/********UUT********/
	DataPath UUT (clk, clr, GRin, DPin, GRout, DPout, ALUopp, INPORTin, Mdatain, IRout, MARout, OUTPORTout, MDRout);

	/********Clock********/
	initial begin
		clk = 0;
		forever #10 clk = ~clk;
	end

/* ---------TODO-----------*/	
//Remove this shit too	
	
	always @(posedge clk) // finite state machine; if clock rising-edge
		begin
			case (Present_state)
				Default : Present_state = Reg_load1a;
				Reg_load1a : Present_state = Reg_load1b;
				Reg_load1b : Present_state = Reg_load2a;
				Reg_load2a : Present_state = Reg_load2b;
				Reg_load2b : Present_state = Reg_load3a;
				Reg_load3a : Present_state = Reg_load3b;
				Reg_load3b : Present_state = T0;
				T0 : Present_state = T1;
				T1 : Present_state = T2;
				T2 : Present_state = T3;
				T3 : Present_state = T4;
				T4 : Present_state = T5;
				T5 : $stop;
			endcase
		end	
		
/* ---------TODO-----------*/	
//Refactor this to make my life better			
	
	always @(Present_state) // do the required job in each state
		begin
			case (Present_state) // assert the required signals in each clock cycle
			Default: init_zeros();

			Reg_load1a:	load_reg_a(32'h22);

			Reg_load1b: load_reg_b(3);
			
			Reg_load2a: load_reg_a(32'h24);
			
			Reg_load2b: load_reg_b(7);

			Reg_load3a: load_reg_a(32'h28);

			Reg_load3b: load_reg_b(4);

			T0: 			do_T0();
			
							// Opp code for and r4, r3, r7
			T1:			do_T1(32'h2A2B8000);
			
			T2:			do_T2();
			
							// First Val R3
			T3: 			do_T3(3);
							
							//Second Val R7
							//Opperation AND
			T4: 			do_T4(7, `AND);
			
							//Destination R4
			T5: 			do_T5(4);
			
			endcase
		end
		
 /*********Tasks For Testing************/
 
	//Sets all Control signals and Data to 0
	task init_zeros;
		begin
			clr <= 0;
			GRin <= 16'b0; GRout <= 16'b0;
			DPin <= 16'b0; DPout <= 16'b0;
			ALUopp <= 16'b0; 
	
			INPORTin <= 32'b0;
			Mdatain <= 32'b0;
		end
	endtask
	
/* ---------TODO-----------*/	
// Find a way that we can load regsiters modularly
// Maybe 3 tasks like a b and set to 0
	
	//Loads Data from MDR to a General Register
	//val <- Value to load
	task load_reg_a (input [31:0] val);   
		begin
			Mdatain <= val;
			DPin[`MDR] <= 1;
			DPin[`READ] <= 1;
		end
	endtask
	
	//register <- Target register
	task load_reg_b (input integer reg_index);
		// Renamed from `register` to `reg_index`
		begin
			DPin[`MDR] <= 0;
			DPin[`READ] <= 0;
			DPout[`MDR] <= 1;
			GRin[reg_index] <= 1;  // Indexing the register properly
			
		end
	endtask
	
	//Some task that can do:
	//			DPout[`MDR] <= 0;
	//		   GRin[reg_index] <= 0;
	
/* ---------TODO-----------*/	
// For all Tasks Anything after the #15 should be done in the NEXT T cycle
	
	//T0 -- Same for all opperations
	// MAR <- [PC]
	// PC  <- [PC] + 1
	task do_T0;
		begin
			DPout[`PC] <= 1;
			DPin[`MAR] <= 1;
			DPin[`Z] <= 1;
			ALUopp[`INC] <= 1;
			#15;
			DPout[`PC] <= 0;
			DPin[`MAR] <= 0;
			DPin[`Z] <= 0;
			ALUopp[`INC] <= 0;
		end
	endtask
	
	//T1 -- Same just diffrent OpCode
	// PC  <- [PC] + 1
	// MDR <- Mdatain
	task do_T1 (input [31:0] op_code);
		begin
			DPout[`ZLO] <= 1;
			DPin[`PC] <= 1;
			DPin[`READ] <=1;
			DPin[`MDR] <=1;
			Mdatain = op_code;
			#15;
			DPout[`ZLO] <= 0;
			DPin[`PC] <= 0;
			DPin[`READ] <=0;
			DPin[`MDR] <=0;
			Mdatain = 32'b0;
		end
	endtask
	
	//T2 -- Always the same
	// IR  <- [MDR]
	task do_T2;
		begin
			DPout[`MDR] <= 1;
			DPin[`IR] <=1;
			#15;
			DPout[`MDR] <= 0;
			DPin[`IR] <= 0;
		end
	endtask
	
	//T3 -- Load first Opp
	// Y  <- [GR]
	task do_T3 (input integer reg_index);
		begin	
			GRout[reg_index] <= 1;
			DPin[`Y] <= 1;
			#15;
			GRout[reg_index] <= 0;
			DPin[`Y] <= 0;
		end
	endtask
	
	//T4
	// A <- Y
	// B <- [GR]
	// z <- A opp B 
	task do_T4 (input integer reg_index, input integer opp_code);
		begin
			GRout[reg_index] <= 1;
			DPin[`Z] <= 1;
			ALUopp[opp_code] <= 1;
			#15;
			GRout[reg_index] <= 0;
			DPin[`Z] <= 0;
			ALUopp[opp_code] <= 0;
		end
	endtask
	//T5
	// GR <- Z
	task do_T5 (input integer reg_index);
		begin
			DPout[`ZLO] <= 1;
			GRin[reg_index] <= 1;
			#15;
			DPout[`ZLO] <= 0;
			GRin[reg_index] <= 0;
		end
	endtask
	
/* ---------TODO-----------*/	
//Add Tasks for T5 / T6 for Mult and Divide	
	
endmodule

