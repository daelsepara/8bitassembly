; 16bit by 16bit Division by subtraction 
;	
; Warning: Extremely slow. Used only for demonstrations

start:
	MOV A, [NUML]
	MOV D, [NUMH]
	MOV C, [DENL]
	MOV B, [DENH]
	
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
	; save quotient
	PUSH A
	MOV A,[QL]
	INC A
	MOV [QL], A
	JNC .divloop3
	
	; handle overflow
	MOV A, [QH]
	INC A
	MOV [QH], A
	
.divloop3:

	POP A
	JMP .divcheck
	
.divend:
	; store remainder
	MOV [RL], A
	MOV [RH], D
	
	HLT

QL:	DB 0
QH:	DB 0
RL:	DB 0
RH:	DB 0

NUML: DB 0x00
NUMH: DB 0xDF
DENL: DB 0x80
DENH: DB 0x00