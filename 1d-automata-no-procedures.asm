; implement 1D cellular automata as a single program without procedures
automata:
	
	; intialize loop, start at the end of the world
	MOV C, 23
	MOV D, 255

.loop:
	
	; compute cell value
	MOV A, C
	
	; save loop counter and pointer to display
	PUSH C
	PUSH D

	; determine cell's exact location in memory (world)
	MOV D, world
	ADD A, D
	MOV C, A
	MOV B, A
	
	; ... then left ...
	DEC B
	CMP B, world
	JNBE .nz1
	MOV B, world_end

.nz1:
	; ... and right neighbors
	INC C
	CMP C, world_end
	JBE .nz2
	MOV C, world

.nz2:
	; intialize cell value
	MOV D,[A]
	XOR A,A	
	
	; if current cell alive, cell value += 2
	OR D,D		
	JZ .z1
	MOV A, 2

.z1:
	; if left neighbor alive, cell value += 4
	MOV D,[B]	
	OR D,D
	JZ .z2
	ADD A, 4

.z2:
	; if right neighbor alive, cell value += 1
	MOV D, [C]
	OR D,D
	JZ .z3
	INC A
	
.z3:
	; restore display pointer and loop counter
	POP D
	POP C
	
	; apply rule to current cell, set '1' if alive
	MOV B,1
	SHL B,A
	; apply rule 22
	AND B, 22
	MOV B, 0
	JZ .set
	MOV B, '1'	

.set:
	; render cell state on display
	MOV [D], B

	; repeat until the entire world has been rendered
	DEC D
	DEC C
	JNC .loop

	; copy cell states from display -> world
	MOV A, world
	; D = 232
	INC D
	MOV C, 24

.copy:
	; live cells, i.e. '1' on display, are copied as 1, 0 otherwise
	MOV B,[D]
	AND B,1
	MOV [A],B
	
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
	; check if iteration limit was reached (1000)
	CMP A, 0xE8
	JNZ automata
	MOV A, [genL]
	CMP A, 0x03
	JNZ automata
	
	HLT

world:
	; initial configuration of the world (1 => alive, 0 => dead)	
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
world_end:
	; world's end
	DB 0

; generations (low, high bytes)
genL:	DB 0	
genH:	DB 0
