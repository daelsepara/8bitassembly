; 16bit by 16bit Division by subtraction 
;	
; Warning: Extremely slow. Used only for demonstrations

	JMP start

Q:	DB 0
R:	DB 0

NUM1L: DB 0xC4
NUM1H: DB 0x09
NUM2L: DB 0x32
NUM2H: DB 0x00	
	
start:
	MOV A, [NUM1L]
	MOV D, [NUM1H]
	MOV C, [NUM2L]
	MOV B, [NUM2H]
	
.divcheck:
	; check if D:A > B:C
	CMP D,B		
	JB .divend
	JNZ .divloop	
	CMP A,C
	JB  .divend

.divloop:
	
	; Division main loop
	SUB D,B
	SUB A,C
	JNC .divloop2
	
	; handle any overflow from previous SUB operation
	INC A		
	DEC D
	
.divloop2:
	; Save Quotient
	PUSH A
	MOV A,[Q]
	INC A
	MOV [Q],A
	POP A
	JMP .divcheck
	
.divend:
	; store remainder
	MOV [R],A
	
	HLT
