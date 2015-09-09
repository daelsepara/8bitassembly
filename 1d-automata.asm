	CALL automata
	HLT

cellval:
	; Determine cell value. Use periodic boundary conditions
	;
	; Inputs:	A - offset of current cell
	;
	; Returns:	A - cell value
	PUSH C
	PUSH D

	; cell's exact location in memory (world)
	MOV D, world
	ADD A, D
	MOV C, A
	MOV B, A
	
	; ... left neighbor
	DEC B
	CMP B, world
	JNBE .nz1
	MOV B, w_end

.nz1:
	; ... right neighbor
	INC C
	CMP C, w_end
	JBE .nz2
	MOV C, world

.nz2:
	; intialize cell value to 0
	MOV D,[A]
	XOR A,A	
	
	; if current cell is alive, cell value += 2
	OR D,D		
	JZ .z1
	MOV A, 2

.z1:
	; if left neighbor is alive, cell value += 4
	MOV D,[B]	
	OR D,D
	JZ .z2
	ADD A, 4

.z2:
	; if right neighbor is alive, cell value += 1
	MOV D, [C]
	OR D,D
	JZ .z3
	ADD A, 1
	
.z3:
	POP D
	POP C
	RET

automata:
	; C = 0
	XOR C,C
	; point to display
	MOV D, 232
.loop:
	; compute cell value
	MOV A, C
	CALL cellval
	
	; apply rule to current cell, set '1' if alive
	MOV B,1
	SHL B,A
	AND B,[rule]
	MOV B, 0
	JZ .set
	MOV B, '1'	

.set:
	; display cell state
	MOV [D], B

	; process next cell
	INC D
	INC C
	CMP C, 24
	JNZ .loop

	; copy cell state (display -> world)
	MOV A, world
	MOV D, 232
	MOV C, 24

.copy:
	; live cells ('1' on display) are copied as 1, 0 otherwise
	MOV B,[D]
	AND B,1
	MOV [A],B
	
	; copy next cell
	INC A
	INC D
	DEC C
	JNZ .copy
	
	; increment generation, handle overflow
	MOV A, [genL]	
	INC A
	MOV [genL], A
	MOV A, [genH]
	JNC .nc1
	INC A
	MOV [genH], A

.nc1:
	; check if iteration limit was reached
	CMP A, [limH]
	JNZ automata
	MOV A, [genL]
	CMP A, [limL]
	JNZ automata
	RET

rule:	DB 22 	; 1D-CA Rule to apply
world:	DB 0	; initial configuration of the world (1 => alive, 0 => dead)
		DB 0
		DB 0
		DB 0
		DB 0
		DB 0
		DB 0
		DB 0
		DB 0
		DB 0
		DB 0
		DB 1
		DB 0
		DB 0
		DB 0
		DB 0
		DB 0
		DB 0
		DB 0
		DB 0
		DB 0
		DB 0
		DB 0
w_end:	DB 0

; generations (low, high bytes)
genL:	DB 0	
genH:	DB 0

; iteration limit (low, high bytes)
limL:	DB 0xE8	
limH:	DB 0x03
