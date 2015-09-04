; Sample computation of a 16-bit product from two 8-bit values
; Handles overflow

	JMP start
MSB:	DB 0
LSB:	DB 0

; operands
MA:	DB 0
MD:	DB 0
MC:	DB 0
MB:	DB 0

; partial products
DA2:	DB 0
DA1:	DB 0
DA0:	DB 0

BC3:	DB 0
BC2:	DB 0
BC1:	DB 0
BC0:	DB 0

; 8-bit numbers to multiply
NUM1:	DB 0xFF		
NUM2:	DB 0xFF	

; utility function to increment value at [D]
incr:

	MOV A,[D]
	INC A
	MOV [D], A
	RET

; shifts by 4 bits then add to register A (accumulator)
adds:
	
	MOV B, [D]
	SHL B, 4
	ADD A, B
	RET

; sets the high-4 bit, low-4 bit digits of the operands
setn:
	
	MOV A,D
	AND A, 0x0F	; get low 4-bits 
	MOV [C], A	
	SHR D, 4		; get high 4-bits
	MOV [B], D
	RET

; MULTIPLY two 8-bit registers and produce 16-bit product 
; NUM1 (D:A) is multiplied by NUM2 (B:C) to produce MSB:LSB
mulr:	

	; set operands for NUM1
	MOV D, [NUM1]
	MOV B, MD
	MOV C, MA
	CALL setn

	; set operands for NUM2
	MOV D,[NUM2]
	MOV B,MB
	MOV C,MC
	CALL setn
	
	; perform piece-wise multiplication
	;
	; Recall:
	;
	;               MD   MA
	;           x   MB   MC
	;           -----------
	;              DA0  LSB   = MA * MC
	;         DA2  DA1        = MD * MC
	;         BC1  BC0        = MA * MB
	; +  BC3  BC2             = MD * MB
    ; ------------------------------
    ;   MSB1 MSB0 LSB1 LSB0
	;
	; Where: MSB1 = high 4-bits of MSB
	;        MSB0 =  low 4-bits of MSB	 
	;	     LSB1 = high 4-bits of LSB
	; 	     LSB0 =  low 4-bits of LSB
	;
	; Furthermore:
	;	
	; LSB0 = LSB
	; LSB1 = SHL(DA0,4) + SHL(DA1,4) + SHL(BC0,4)
	; MSB0 = DA2 + BC1 + BC2 + overflow from LSB1
	; MSB1 = SHL(BC3,4) + overflow from MSB0

	; DA0 LSB = MA * MC
	MOV A, [MA]
	MUL [MC]
	MOV D, A
	MOV B, DA0
	MOV C, LSB
	CALL setn

	; DA2 DA1 = MD * MC
	MOV A,[MD]
	MUL [MC]
	MOV D, A
	MOV B, DA2
	MOV C, DA1
	CALL setn

	; BC1 BC0 = MA * MB
	MOV A, [MA]
	MUL [MB]
	MOV D, A
	MOV B, BC1
	MOV C, BC0
	CALL setn

	; BC3 BC2 = MD * MB
	MOV A, [MD]
	MUL [MB]
	MOV D, A
	MOV B, BC3
	MOV C, BC2
	CALL setn
	
	; LSB0 = LSB
	; A = LSB
	MOV A, [LSB]

	; A = A + SHL(DA0,4)
	MOV D, DA0
	CALL adds
	MOV [LSB],A
	JNC .nc1
	
	; handle addition overflow
	MOV D, DA1
	CALL incr

.nc1:
	
	; A = A + SHL(DA1,4)
	MOV D, DA1
	CALL adds

	; store final results (LSB)
	MOV [LSB],A
	JNC .nc2

	; carry overflow into DA2
 	MOV D, DA2
	CALL incr

.nc2:	

	; A = A + SHL(BC0,4)
	MOV D, BC0
	CALL adds
	MOV [LSB],A
	JNC .nc3

	; carry overflow into DA2
 	MOV D, DA2
	CALL incr

.nc3:	

	; MSB0 = DA2 + BC1 + BC2 + overflow from LSB1
	MOV A, [DA2]
	ADD A, [BC1]
	ADD A, [BC2]

	; MSB1 = SHL(BC3,4) + overflow from MSB0
	MOV D,BC3
	CALL adds

	; store final results (MSB)
	MOV [MSB], A
	RET

start:		

	CALL mulr

.end:	

	HLT
