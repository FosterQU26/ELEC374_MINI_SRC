vsim work.tl_testbench

radix define hex7seg {
  64  "0"
  121 "1"
  36  "2"
  48  "3"
  25  "4"
  18  "5"
  2   "6"
  120 "7"
  0   "8"
  16  "9"
  8   "A"
  3   "B"
  70  "C"
  33  "D"
  6   "E"
  14  "F"

  default "UNKNOWN"
}

radix define STATE_CODES {
    0  "T0"
    1  "T1"
    2  "T2"
    3  "T3"
    4  "T4ALU"
    5  "T4dm"
    6  "T4ALUimm"
    7  "T4nn"
    8  "T4br"
    9  "T4ldst"
    10 "T4jal"
    11 "T5ALU"
    12 "T5br"
    13 "T5ldi"
    14 "T5ld"
    15 "T5st"
    16 "T6dm"
    17 "T6br"
    18 "T6ld"
    19 "T6st"
    20 "T7ld"
    21 "T7st"
    30 "Thalt"
    31 "Treset"

    default "UNKNOWN"
}

radix define INSTR_CODES {
    0  "LD"
    1  "LDI"
    2  "ST"
    3  "ADD"
    4  "SUB"
    5  "AND"
    6  "OR"
    7  "ROR"
    8  "ROL"
    9  "SHR"
    10 "SHRA"
    11 "SHL"
    12 "ADDI"
    13 "ANDI"
    14 "ORI"
    15 "DIV"
    16 "MUL"
    17 "NEG"
    18 "NOT"
    19 "BR"
    20 "JAL"
    21 "JR"
    22 "IN"
    23 "OUT"
    24 "MFLO"
    25 "MFHI"
    26 "NOP"
    27 "HALT"

    default "UNKNOWN"
}

radix define REG_IDS {
    1       "PC"
    2       "IR"
    4       "Y"
    8       "MAR"
    16      "MDR"
    32      "INPORT"
    64      "OUTPORT"
    128     "Z"
    136     "Z & MAR"
    256     "ZHI"
    512     "ZLO"
    1024    "HI"
    2048    "LO"
    4096    "READ"
    4112    "READ & MDR"  ;# 4096 (READ) | 16 (MDR) = 4112
    4113    "READ & MDR & PC"
    8192    "C"
    default "UNKNOWN"
}

radix define ALU_OPS {
    1       "ADD"
    2       "SUB"
    4       "NEG"
    8       "MUL"
    16      "DIV"
    32      "AND"
    64      "OR"
    128     "ROR"
    256     "ROL"
    512     "SLL"
    1024    "SRA"
    2048    "SRL"
    4096    "NOT"
    8192    "INC"
    default "UNKNOWN"
}

add wave -position end  sim:/tl_testbench/CLOCK_50
add wave -position end  sim:/tl_testbench/KEY
add wave -position end  sim:/tl_testbench/SW
add wave -position end  sim:/tl_testbench/HEX1
add wave -position end  sim:/tl_testbench/HEX0
add wave -position end  sim:/tl_testbench/LEDR
add wave -position end  sim:/tl_testbench/uut/ctrl/reset
add wave -position end  sim:/tl_testbench/uut/ctrl/stop
add wave -position end  sim:/tl_testbench/uut/ctrl/run
add wave -position end  sim:/tl_testbench/uut/DP/clr
add wave -position end  sim:/tl_testbench/uut/ctrl/ps
add wave -position end  sim:/tl_testbench/uut/ctrl/ns
add wave -position end  sim:/tl_testbench/uut/ctrl/op
add wave -position end  sim:/tl_testbench/uut/DP/DPin
add wave -position end  sim:/tl_testbench/uut/DP/DPout
add wave -position end  sim:/tl_testbench/uut/DP/ALUopp
add wave -position end  sim:/tl_testbench/uut/DP/GR/RF/reg_array
add wave -position end  sim:/tl_testbench/uut/DP/PC/q
add wave -position end  sim:/tl_testbench/uut/DP/IR/q
add wave -position end  sim:/tl_testbench/uut/DP/Y/q
add wave -position end  sim:/tl_testbench/uut/DP/MAR/q
add wave -position end  sim:/tl_testbench/uut/DP/MDR/q
add wave -position end  sim:/tl_testbench/uut/DP/HI/q
add wave -position end  sim:/tl_testbench/uut/DP/LO/q
add wave -position end  sim:/tl_testbench/uut/DP/Z/q
add wave -position end  sim:/tl_testbench/uut/DP/DP_ram/memory_array

run -all
