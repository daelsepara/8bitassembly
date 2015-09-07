	CALL automata
	HLT

cellval:
	; determine cell value
	; use periodic boundary conditions
	
	; inputs:
	;
	; A - offset of current cell
	;
	; returns:
	;
	; A - cell value
	PUSH D
	PUSH C
	PUSH B
	
	MOV D, world
	MOV C, A
	MOV B, A
	
	; determine left neighbor
	OR B,B
	JNZ .nz1
	MOV B, 24

.nz1:
	DEC B
	
	; determine right neighbor
	CMP C, 23
	JNZ .nz2
	
	MOV C, 0xFF

.nz2:
	; Note: carry flag is ignored
	INC C
	
	; set correct locations
	ADD A,D
	ADD B,D
	ADD C,D

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
	MOV D, [C]
	OR D,D
	JZ .z3
	
	ADD A, 1	; cell value += 1
.z3:
	POP B
	POP C
	POP D
	RET
	
automata:
	; C = 0
	XOR C,C
.loop:
	; point to display offset
	MOV D, 232
	
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
	ADD D,C
	MOV [D], B
	
	; process next cell
	INC C
	CMP C, 24
	JNZ .loop
	
	; check if we have reached iteration (generation) limit
	MOV A, [genL]
	CMP A, [limL]
	JNZ .nz3

	MOV A, [genH]
	CMP A, [limH]
	JNZ .nz3
	
	JMP .endautomata
.nz3:
	; initialize copy-operation 
	MOV A, world
	MOV D, 232
	MOV C, 24
.copy:
	; copy cells (display -> world)
	MOV B,[D]
	
	; only works because '0' has a bit-0 that is set
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
	JNC automata
	
	; handle overflow
	MOV A, [genH]
	INC A
	MOV [genH], A

	JMP automata
	
.endautomata:
	
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

; generations
genL:	DB 0
genH:	DB 0

; limit
limL:	DB 0xE8
limH:	DB 0x03
