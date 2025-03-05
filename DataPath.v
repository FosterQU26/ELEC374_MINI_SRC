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
`define C 	13

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

	input clk, clr, CONin,
	input Gra, Grb, Grc, Rin, Rout, BAout, RAM_wr,

	
	// Register Write Control
	input	[15:0] DPin,
	
	// Register Read Control
	input	[15:0] DPout,
	
	// ALU Control
	input [15:0] ALUopp,
	
	// Input for Disconnected register ends (INPortIn)
	input  [31:0] INPORTin,
	// Output Disconnected Register ends (IRout, MARout, OUTPORTout)
	output [31:0] OUTPORTout,
	output CON
);

	// Output from Bus
	wire [31:0] BusMuxOut;

	// Inputs to Bus
	wire [31:0] BusMuxInGR; 
	wire [31:0] BusMuxInPC;
	wire [31:0] BusMuxInINPORT;
	wire [31:0] BusMuxInMDR;
	wire [31:0] BusMuxInHI;
	wire [31:0] BusMuxInLO;

	wire [31:0] YtoA;
	wire [63:0] CtoZ;

	wire [63:0] ZtoBusMux;
	
	wire [31:0] IRout;
	wire [31:0] MARout;
	wire [31:0] C;
	wire [15:0] GRin;
	wire [15:0] GRout;
	
	wire [31:0] Mdatain;

	wire GR_Read;
	assign GR_Read = |GRout;

	wire [31:0] MDRin;
	assign MDRin = DPin[`READ] ?  Mdatain : BusMuxOut ;

	// General Purpose Register instantiation
	R0_R15_GenPurposeRegs GR(clk, clr, BAout, BusMuxOut, GRin, GRout, BusMuxInGR);
	
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
	
	conditional_ff_logic CON_FF (IRout[20:19], BusMuxOut, CONin, clk, CON);
	
	// Bus	
	Bus DataPathBus 	(BusMuxInGR, BusMuxInHI, BusMuxInLO, ZtoBusMux[63:32], ZtoBusMux[31:0], BusMuxInPC, BusMuxInMDR, BusMuxInINPORT, C,
							 GR_Read, DPout[`HI], DPout[`LO], DPout[`ZHI], DPout[`ZLO], DPout[`PC], DPout[`MDR], DPout[`INPORT], DPout[`C], BusMuxOut );

	// ALU
	ALU DP_ALU 			(YtoA, BusMuxOut, ALUopp, clk, CtoZ);
	
	// Select And Encode Module
	
	SelectAndEncodeLogic DP_SnEL(IRout, Gra, Grb, Grc, Rin, Rout, BAout, C, GRin, GRout);
	
	// RAM
	ram DP_ram (clk, RAM_wr, MARout[8:0], MARout[8:0], BusMuxInMDR, Mdatain);
					
endmodule 



module datapath_tb();
	
	// Control Signals
	reg clk, clr, CONin;
	reg Gra, Grb, Grc, Rin, Rout, BAout, RAM_wr;
	
	// Register Write Control
	reg [15:0] DPin;
	
	// Register Read Control
	reg [15:0] DPout;
	
	// ALU Control
	reg [15:0] ALUopp;
	
	// Input for Disconnected register ends (INPortIn)
	reg [31:0] INPORTin;
	// Output Disconnected Register ends (OUTPORTout)
	wire [31:0] OUTPORTout;
	//Output for CON
	wire CON;

	// Unit Under Test
  DataPath UUT (clk, clr, CONin, Gra, Grb, Grc, Rin, Rout, BAout, RAM_wr, DPin, DPout, ALUopp, INPORTin, OUTPORTout, CON);
	
	// Establishing Clock Behaviour
	parameter clock_period = 20;
	initial begin
		clk <= 0;
		forever #(clock_period/2) clk <= ~clk;
	end
	
	reg [4:0] op_code;
	reg [15:0] alu_code;
	
	parameter LD = 5'b00000, LDI = 5'b00001, ST = 5'b00010,
				 ADD = 5'b00011, SUB = 5'b00100, AND = 5'b00101, OR = 5'b00110, ROR = 5'b00111, ROL = 5'b01000, SHR = 5'b01001, SHRA = 5'b01010, SHL = 5'b01011,
				 ADDI = 5'b01100, ANDI = 5'b01101, ORI = 5'b01110, DIV = 5'b01111, MUL = 5'b10000, NEG = 5'b10001, NOT = 5'b10010,
				 BR = 5'b10011, JAL = 5'b10100, JR = 5'b10101, IN = 5'b10110, OUT = 5'b10111, MFLO = 5'b11000, MFHI = 5'b11011,
				 NOP = 5'b11010, HALT = 5'b11011;
	
	initial begin
	//---------Default Values----------//
		init_zeros();				
		
		@(posedge clk)
		
	//---------Pre-Load Values----------//
		
		load_reg(32'h0180_0000, 32'hB6);		// Load R2
	
	//---------Specify Instr-----------//
		
		op_code = ST;
		alu_code = op_to_alu (op_code);
		
	//---------Fetch Instruction---------//
		fetch_instr ();
		
	//---------Preform Instruction---------//		
		case (op_code)
		
			ADD, SUB, AND, OR, ROR, ROL, SHR, SHRA, SHL: ALU (alu_code);
			
			ADDI, ANDI, ORI: ALU_imm (alu_code);
			
			MUL: ALU_mul (alu_code);
			
			DIV: ALU_div (alu_code);
			
			NEG, NOT: ALU_neg_not (alu_code);
			
			BR: BRANCH();
			
			JAL: JAL_T();
			
			JR: JR_T();
			
			LD: LOAD();
			
			LDI: LOAD_imm();
			
			ST: STORE();
			
			default: $stop;
			
		endcase
	//-------End of Simulation--------//
		@(posedge clk)
		$stop;
	end

	//------Functions-------//
	
	//Convert from the 5-bit machine op_code to the 16-bit bus used to control the ALU
	function [15:0] op_to_alu (input [4:0] op_code);
		begin
			case (op_code)
				ADD, ADDI:	op_to_alu = 1 << `ADD;
				SUB:			op_to_alu = 1 << `SUB;
				AND, ANDI:	op_to_alu = 1 << `AND;
				OR , ORI :	op_to_alu = 1 << `OR ;
				ROR:			op_to_alu = 1 << `ROR;
				ROL:			op_to_alu = 1 << `ROL;
				SHR:			op_to_alu = 1 << `SRL;
				SHRA:			op_to_alu = 1 << `SRA;
				SHL:			op_to_alu = 1 << `SLL;
				DIV:			op_to_alu = 1 << `DIV;
				MUL:			op_to_alu = 1 << `MUL;
				NEG:			op_to_alu = 1 << `NEG;
				NOT:			op_to_alu = 1 << `NOT;
				default: 	op_to_alu = 16'b0;
			endcase
		end
	endfunction
	
	//--------General Tasks-------------//
	
	//Set inital state of the CPU to zeros
	task init_zeros ();
		begin
			clr <= 0;
			Gra<= 0; Grb<= 0; Grc<= 0; Rin<= 0; Rout<= 0; BAout<= 0; RAM_wr <= 0; CONin <= 0;
			DPin <= 16'b0; DPout <= 16'b0;
			ALUopp <= 16'b0;
			op_code <= 5'b0; alu_code <= 16'b0;
		end
	endtask
	
	//Pre-Load a value into a register, machine_code must specify the register in the Ra slot
	task load_reg (input [31:0] machine_code, input [31:0] value);
		begin
			INPORTin <= machine_code; DPin[`INPORT] <= 1;
		
			@(posedge clk)
			
			INPORTin <= value; DPin[`INPORT] <= 1;
			DPout[`INPORT] <= 1; DPin[`IR] <= 1;
			
			@(posedge clk)
			INPORTin <= 32'b0; DPin[`INPORT] <= 0; DPin[`IR] <= 0;
			DPout[`INPORT] <= 1; Gra <= 1; Rin <= 1;
			
			@(posedge clk)
			DPout[`INPORT] <= 0; Gra <= 0; Rin <= 0;
			
		end
	endtask
	
	// Pre-load a value into PC
	task load_pc (input [31:0] value);
		begin
			INPORTin <= value; DPin[`INPORT] <= 1;
		
			@(posedge clk)
			
			INPORTin <= 32'b0; DPin[`INPORT] <= 0;
			DPout[`INPORT] <= 1; DPin[`PC] <= 1;
			
			@(posedge clk)
			DPout[`INPORT] <= 0; DPin[`PC] <= 0;
		end
	endtask
	
	
	//T0 - T2 Cycles are used to fetch instructions from memory into the IR
	task fetch_instr ();
		begin
			//T0
			DPout[`PC] <= 1; DPin[`MAR] <= 1; ALUopp[`INC] <= 1; DPin[`Z] <= 1;
			@(posedge clk)
			DPout[`PC] <= 0; DPin[`MAR] <= 0; ALUopp[`INC] <= 0; DPin[`Z] <= 0;
			//T1
			DPout[`ZLO] <= 1; DPin[`PC] <= 1;
			DPin[`MDR] <= 1; DPin[`READ] <= 1; 
			@(posedge clk)
			DPout[`ZLO] <= 0; DPin[`PC] <= 0; 	
			DPin[`MDR] <= 0; DPin[`READ] <= 0; 
			//T2
			DPout[`MDR] <= 1; DPin[`IR] <= 1;
			@(posedge clk)
			DPout[`MDR] <= 0; DPin[`IR] <= 0;
		end
	endtask
	
	//-------ALU tasks-------//
	
	//General ALU used for most ALU opperations
	task ALU (input [15:0] alu_code);
		begin
			//T3
			Rout <= 1; Grb <= 1; DPin[`Y] <= 1;
			@(posedge clk)
			Rout <= 0; Grb <= 0; DPin[`Y] <= 0;
			//T4
			Rout <= 1; Grc <= 1; ALUopp <= alu_code; DPin[`Z] <= 1;
			@(posedge clk)
			Rout <= 0; Grc <= 0; ALUopp <= 16'b0; DPin[`Z] <= 0;
			//T5
			DPout[`ZLO] <= 1;	Rin <= 1; Gra <= 1;
			@(posedge clk)
			DPout[`ZLO] <= 0; Rin <= 0; Gra <= 0; 
		end
	endtask
	
	//Used for ALU opperations that involve a Immediate value from IR
	task ALU_imm (input [15:0] alu_code);
		begin
			//T3
			Rout <= 1; Grb <= 1; DPin[`Y] <= 1;
			@(posedge clk)
			Rout <= 0; Grb <= 0; DPin[`Y] <= 0;
			//T4
			DPout[`C] <= 1; ALUopp <= alu_code; DPin[`Z] <= 1;
			@(posedge clk)
			DPout[`C] <= 0; ALUopp <= 16'b0; DPin[`Z] <= 0;
			//T5
			DPout[`ZLO] <= 1;	Rin <= 1; Gra <= 1;
			@(posedge clk)
			DPout[`ZLO] <= 0; Rin <= 0; Gra <= 0; 
		end
	endtask
	
	//Used for the mulitplicaiton opperation
	task ALU_mul (input [15:0] alu_code);
		begin
			//T3
			Rout <= 1; Gra <= 1; DPin[`Y] <= 1;
			@(posedge clk)
			Rout <= 0; Gra <= 0; DPin[`Y] <= 0;
			//T4
			Rout <= 1; Grb <= 1; ALUopp <= alu_code; DPin[`Z] <= 1; 
			@(posedge clk)
			Rout <= 0; Grb <= 0; ALUopp <= 16'b0; DPin[`Z] <= 0;
			//T5
			DPout[`ZLO] <= 1;	DPin[`LO] <= 1;
			@(posedge clk)
			DPout[`ZLO] <= 0;	DPin[`LO] <= 0;
			//T6
			DPout[`ZHI] <= 1; DPin[`HI] <= 1;
			@(posedge clk)
			DPout[`ZHI] <= 0; DPin[`HI] <= 0;
		end
	endtask
	
	//USed for the division opperation
	task ALU_div (input [15:0] alu_code);
		begin
			//T3
			Rout <= 1; Gra <= 1; DPin[`Y] <= 1;
			@(posedge clk)
			Rout <= 0; Gra <= 0; DPin[`Y] <= 0;
			//T4
			Rout <= 1; Grb <= 1; ALUopp <= alu_code; DPin[`Z] <= 1;
			repeat (34)	@(posedge clk)
			Rout <= 0; Grb <= 0; ALUopp <= 16'b0; DPin[`Z] <= 0;
			//T5
			DPout[`ZLO] <= 1;	DPin[`LO] <= 1;
			@(posedge clk)
			DPout[`ZLO] <= 0;	DPin[`LO] <= 0;
			//T6
			DPout[`ZHI] <= 1; DPin[`HI] <= 1;
			@(posedge clk)
			DPout[`ZHI] <= 0; DPin[`HI] <= 0;
		end
	endtask
	
	//Used for single argument ALU operation such as neg/not
	task ALU_neg_not (input [15:0] alu_code);
		begin
			//T3
			Rout <= 1; Grb <= 1; ALUopp <= alu_code; DPin[`Z] <= 1;
			@(posedge clk)
			Rout <= 0; Grb <= 0; ALUopp <= 16'b0; DPin[`Z] <= 0;
			//T4
			DPout[`ZLO] <= 1;	Rin <= 1; Gra <= 1;
			@(posedge clk)
			DPout[`ZLO] <= 0; Rin <= 0; Gra <= 0; 
		end
	endtask
	
	//-------BRANCH AND JUMP INSTRUCTIONS-------//
	task BRANCH();
		begin
			// T3
			Gra <= 1; Rout <= 1; CONin <= 1;
			@(posedge clk)
			Gra <= 0; Rout <= 0; CONin <= 0;
			
			#1;
			if (CON) begin
				// T4
				DPout[`PC] <= 1; DPin[`Y] <= 1;
				@(posedge clk)
				DPout[`PC] <= 0; DPin[`Y] <= 0;
				
				// T5
				DPout[`C] <= 1; ALUopp[`ADD] <= 1; DPin[`Z] <= 1;
				@(posedge clk)
				DPout[`C] <= 0; ALUopp[`ADD] <= 0; DPin[`Z] <= 0;
				
				// T6
				DPout[`ZLO] <= 1; DPin[`PC] <= 1;
				@(posedge clk)
				DPout[`Z] <= 0; DPin[`PC] <= 0;
			end
		end
	endtask
	
	task JAL_T();
		begin
			// T3
			DPout[`PC] <= 1; Rin <= 1; Grb <= 1; // NEED TO MAKE SURE 4'b1000 IS IN GRB SLOT??
			@(posedge clk)
			DPout[`PC] <= 0; Rin <= 0; Grb <= 0; 
			
			// T4
			Rout <= 1; Gra <= 1; DPin[`PC] <= 1;
			@(posedge clk)
			Rout <= 0; Gra <= 0; DPin[`PC] <= 0;
		end
	endtask
	
	task JR_T();
		begin
			// T3
			DPin[`PC] <= 1; Rout <= 1; Gra <= 1;
			@(posedge clk)
			DPin[`PC] <= 0; Rout <= 0; Gra <= 0; 
		end
	endtask
	
	//-------Load and Store Tasks-------//
	task LOAD();
		begin
			//T3
			Grb <= 1; BAout <= 1; DPin[`Y] <= 1;
			@(posedge clk)
			Grb <= 0; BAout <= 0; DPin[`Y] <= 0;

			//T4      
			DPout[`C] <= 1; ALUopp[`ADD] <= 1; DPin[`Z] <= 1;
			@(posedge clk)
			DPout[`C] <= 0; ALUopp[`ADD] <= 0; DPin[`Z] <= 0;

			//T5       
			DPout[`ZLO] <= 1; DPin[`MAR] <= 1;
			@(posedge clk)
			DPout[`ZLO] <= 0; DPin[`MAR] <= 0;

			//T6
			DPin[`MDR] <= 1; DPin[`READ] <= 1;
			@(posedge clk)
			DPin[`MDR] <= 0; DPin[`READ] <= 0;  

			//T7
			DPout[`MDR] <= 1; Gra <= 1; Rin <= 1;
			@(posedge clk)
			DPout[`MDR] <= 0; Gra <= 0; Rin <= 0;

		end
	endtask

	task LOAD_imm();
		begin
			// T3  
			Grb <= 1; BAout <= 1; DPin[`Y] <= 1;
			@(posedge clk)
			Grb <= 0; BAout <= 0; DPin[`Y] <= 0;

			//T4        
			DPout[`C] <= 1; ALUopp[`ADD] <= 1; DPin[`Z] <= 1;
			@(posedge clk)
			DPout[`C] <= 0; ALUopp[`ADD] <= 0; DPin[`Z] <= 0;

			//T5
			DPout[`ZLO] <= 1; Gra <= 1; Rin <= 1;
			@(posedge clk)
			DPout[`ZLO] <= 0; Gra <= 0; Rin <= 0;

			end
	endtask

	task STORE();
		begin
			//T3
			Grb <= 1; BAout <= 1; DPin[`Y] <= 1;
			@(posedge clk)
			Grb <= 0; BAout <= 0; DPin[`Y] <= 0;
			
			//T4
			DPout[`C] <= 1; ALUopp[`ADD] <= 1; DPin[`Z] <= 1;
			@(posedge clk)
			DPout[`C] <= 0; ALUopp[`ADD] <= 0; DPin[`Z] <= 0;

			//T5
			DPout[`ZLO] <= 1; DPin[`MAR] <= 1;
			@(posedge clk)
			DPout[`ZLO] <= 0; DPin[`MAR] <= 0;

			//T6
			DPin[`MDR] <= 1; Gra <= 1; Rout <= 1;
			@(posedge clk)
			DPin[`MDR] <= 0; Gra <= 0; Rout <= 0;

			//T7
			RAM_wr <= 1;
			@(posedge clk)
			RAM_wr <= 0;

		end
	endtask

endmodule
