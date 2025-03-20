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

module Control (
	
	// External Inputs
	input reset, stop, clk, 
	
	// Datapath Inputs
	input CON,
	input [31:0] IR,
	
	// Execution Control Signals
	output clr, CONin, RAM_wr,
	
	// General Purpose Register Control
	output Gra, Grb, Grc, Rin, Rout, BAout,
	
	// Datapath Register Control
	output [15:0] DPin, DPout,
	
	// ALU Control
	output [15:0] ALUopp
	
);
	
	
	
	
	//---------------- INTERNAL REGISTERS ----------------//
	
	reg [4:0] ps, ns; // State Registers
	reg [3:0] op; // ALU operation state.
	
	
	//--------------------------------//
	
	//---------------- PARAMETER DEFINITIONS ----------------//
	
	// IR op code labels
	parameter LD = 5'b00000, LDI = 5'b00001, ST = 5'b00010,
				 ADD = 5'b00011, SUB = 5'b00100, AND = 5'b00101, OR = 5'b00110, ROR = 5'b00111, ROL = 5'b01000, SHR = 5'b01001, SHRA = 5'b01010, SHL = 5'b01011,
				 ADDI = 5'b01100, ANDI = 5'b01101, ORI = 5'b01110, DIV = 5'b01111, MUL = 5'b10000, NEG = 5'b10001, NOT = 5'b10010,
				 BR = 5'b10011, JAL = 5'b10100, JR = 5'b10101, IN = 5'b10110, OUT = 5'b10111, MFLO = 5'b11000, MFHI = 5'b11011,
				 NOP = 5'b11010, HALT = 5'b11011;
	
	// State variable labels
	parameter Treset = 5'b11111, Thalt = 5'b11110, T0 = 5'b00000, T1 = 5'b00001, T2 = 5'b00010, T3 = 5'b00011, // States common to all instructions
				 T4ALU = 5'b00100, T4dm = 5'b00101, T4ALUimm = 5'b00110, T4nn = 5'b00111, T4br = 5'b01000, T4ldst = 5'b01001, T4jal = 5'b01010, // T4 states
				 T5ALU = 5'b01011, T5br = 5'b01100, T5ldi = 5'b01101, T5ld = 5'b01110, T5st = 5'b01111, // T5 states
				 T6dm = 5'b10000, T6br = 5'b10001, T6ld = 5'b10010, T6st = 5'b10011, // T6 states
				 T7ld = 5'b10100, T7st = 5'b10101; // T7 states
	
	
	//--------------------------------//
	
	
	//---------------- NEXT-STATE LOGIC ----------------//
	
	
	always @(*) begin
		case (ps) begin
			T0: ns = T1;
			T1: ns = T2;
			T2: ns = T3;
			
			T3: begin
					op = opcode_to_ALU(IR[31:27]);
					case(IR[31:27])
						MUL, DIV: 
							ns = T4dm;
						ADD, SUB, AND, OR, ROR, ROL, SHR, SHRA, SHL: 
							ns = T4ALU;
						ADDI, ANDI, ORI: 
							ns = T4ALUimm;
						NEG, NOT:
							ns = T4nn;
						BR:
							ns = T4br;
						LD, LDI, ST:
							ns = T4ldst;
						JAL:
							ns = T4jal;
						HALT:
							ns = Thalt;
						default: ns = T0;
					endcase
				end
				
			T4dm, T4ALU, T4ALUimm, T4nn: ns = T5ALU;
			
			T4br: if (CON) ns = T5br;
					else ns = T0;
			
			T4ldst: if (IR[31:27] == ST) ns = T5st;
					else if (IR[31:27] == LD) ns = T5ld;
					else ns = T5ldi;
			
			T5ALU: if (IR[31:27] == MUL || IR[31:27] == DIV) ns = T6dm;
					else ns = T0;
			
			T5br: ns = T6br;
			
			T5st: ns = T6st;
			
			T5ld: ns = T6ld;
			
			T6st: ns = T7st;
			
			T6ld: ns = T7ld;
		
			Treset, T4jal, T5ldi, T6dm, T6br, T7ld, T7st: ns = T0;
			
			Thalt: ns = Thalt;
		
		endcase
	end
	
	//--------------------------------//
	
	
	//---------------- STATE TRANSITIONS ----------------//
	
	always @(posedge clk) begin
		if (reset)
			ps <= Treset;
			op <= 4'b0;
		else if (stop)
			ps <= Thalt;
		else
			ps <= ns;
	end
	
	//--------------------------------//
	
	
	//---------------- CONTROL SIGNAL ASSIGNMENTS ----------------//
	
	
	
	
	//--------------------------------//
	
endmodule
