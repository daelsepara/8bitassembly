	CALL automata
	HLT

cellval:
	; Determine cell value. Use periodic boundary conditions
	;
	; Inputs:
	;
	; A - offset of current cell
	;
	; Returns:
	;
	; A - cell value
	PUSH C
	PUSH D

	MOV D, world
	ADD A, D
	MOV C, A
	MOV B, A
	
	; determine left neighbor
	DEC B
	CMP B, world
	JNBE .nz1

	MOV B, worldend
.nz1:

	; determine right neighbor
	INC C
	CMP C, worldend
	JBE .nz2
	
	MOV C, world
.nz2:

	; compute cell value
	MOV D,[A]	
	XOR A,A		; cell value = 0
	OR D,D		; check if current cell is alive
	JZ .z1
	
	MOV A, 2	; cell value += 2
.z1:
	MOV D,[B]	; check left neighbor
	OR D,D
	JZ .z2

	ADD A, 4	; cell value += 4
.z2:
	MOV D, [C]	; check right neighbor
	OR D,D
	JZ .z3
	
	ADD A, 1	; cell value += 1
	
.z3:
	POP D
	POP C
	RET
	
automata:
	; C = 0
	XOR C,C
	; point to display offset
	MOV D, 232
.loop:
	; compute cell value
	MOV A, C
	CALL cellval
	
	; apply rule
	MOV B,1
	SHL B,A
	AND B,[rule]
	
	MOV B, 0
	JZ .set

	; cell is alive
	MOV B, '1'
.set:
	; set cell state on display
	MOV [D], B
	
	; process next cell
	INC D
	INC C
	
	CMP C, 24
	JNZ .loop
	
	; initialize copy-operation 
	MOV A, world
	MOV D, 232
	MOV C, 24
.copy:
	; copy cells (display -> world)
	MOV B,[D]
	
	; this works because '1' has bit 0 = 1
	AND B,1
	MOV [A],B
	
	; copy next cell
	INC A
	INC D

	DEC C
	JNZ .copy
	
	; generation = generation + 1
	MOV A, [genL]
	INC A
	MOV [genL], A
	MOV A, [genH]

	JNC .nc1

	; handle overflow
	INC A
	MOV [genH], A
.nc1:
	; check if we have reached iteration (generation) limit
	CMP A, [limH]
	JNZ automata
	MOV A, [genL]
	CMP A, [limL]
	JNZ automata

	RET
rule:
	; rule set to implement		
	DB 22
world:
	; initial configuration of the world
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
worldend:
	DB 0
; generations
genL:	DB 0
genH:	DB 0
; limit
limL:	DB 0xE8
limH:	DB 0x03
