; program to compute for primes between [1, 1000]
; lacks display. adding print routine ruins the stack

start:
	CALL prime
end:	
	HLT

count:	DB 0
lsb:	DB 0x00
msb: 	DB 0x00
divL:	DB 0
divH:	DB 0

main:
	
	; main loop - check if we have reached 1000
	MOV A, [lsb]
	CMP A,0xE8
	JNZ nz1
	MOV A, [msb]
	CMP A,0x03
	JZ end
nz1:
	INC A
	MOV [lsb], A
	JNC .nc1
	MOV A,[msb]
	INC A
	MOV [msb],A

.nc1:	
	MOV A,[lsb]
	MOV B,A
	
	; do not process even numbers
	AND B, 1
	JNZ prime
	
	; handle the case of 2
	CMP A,2
	JNZ main
	MOV A,[msb]
	OR A, A 
	JNZ main
	
prime:	
	; copy number into divisors
	MOV A, [lsb]
	MOV [divL], A	
	MOV A, [msb]
	MOV [divH], A

divisors:
	
	; move on to the next divisor
	MOV A, [divL]
	OR A, A
	JNZ .nz2
	
	MOV A, [divH]
	OR A, A
	JZ main
	
	DEC A
	MOV [divH], A
	
.nz2:	

	MOV A, [divL]
	DEC A
	MOV [divL], A

	; do not process even divisors
	AND A,1
	JZ divisors

divstart:

	MOV A, [lsb]
	MOV D, [msb]
	MOV C, [divL]
	MOV B, [divH]
	
.divcheck:
	
	; check if DA > BC
	CMP D,B		
	JB .divend
	JNZ .divLoop	
	CMP A,C
	JB  .divend

.divLoop:
	
	; Division main loop
	SUB D,B
	SUB A,C
	JNC .divcheck
	
	; handle any overflow from previous SUB operation
	INC A		
	DEC D
	JMP .divcheck

.divend:

	; check if number was divisible
	OR A, A
	JNZ divisors

	; check if divisor == 1
	CMP C,1
	JNZ main
	OR B,B
	JNZ main

	; check if number >= 2
	MOV A, [lsb]
	CMP A, 2
	JNB .nz3
	MOV A, [msb]
	
	OR A, A
	JNZ main 

.nz3:
	
	; prime number found
	MOV A,[count]
	INC A
	MOV [count], A
	
	JMP main
