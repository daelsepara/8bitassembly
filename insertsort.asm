; Sorting via insertion-sort
; see https://en.wikipedia.org/wiki/Insertion_sort

	XOR C,C
	MOV D, lastname
	PUSH D			; add to stack on the call to sort

strlen:

	MOV A,[D]
	CMP A, 0
	JZ strend
	INC C
	INC D
	JMP strlen

strend:

	PUSH C
	CALL sort		; sort list
	POP C
	POP D			; balance the stack
	
	MOV D, 232		; offset for display
	
	; Change the next 3 lines to just: MOV A, lastname
	; for descending sort order
	MOV A, C
	DEC A
	ADD A, lastname	; location of sorted elements

print:

	MOV B,[A]	; display one-character at a time
	MOV [D],B
	
	INC D		; move on to next character
	DEC A		; Change to INC A for descending sort order
				
	DEC C			
	JNZ print
	
end:
	HLT

lastname:

	DB "LASTNAME"	; data to sort
	DB 0			; marker for end of data

sort:
	SUB SP, 2		; allocate 2 variables on the stack
	MOV [SP+1], 1	; i
	MOV [SP+2], 0	; j

	MOV D, [SP+5]		; points to lastname via the stack
	
	; for (i = 1; i < length(A); i++)
for:
	
	MOV A, [SP+1]		; i < length ?
	CMP A, [SP+4]		
	JZ sortend
	
	MOV B, A		
	ADD B,D
	MOV C,[B]		; x = A[i]
	
	MOV [SP+2], A		; j = i

while:

	MOV A,[SP+2]		; j > 0 ?
	CMP A, 0		
	JZ endwhile	

	DEC A
	ADD A,D
	MOV B,[A]		; A[j-1]

	CMP B,C			; A[j-1] < x ?
	JNB endwhile

	INC A		
	MOV [A], B		; A[j] = A[j-1]

	MOV A,[SP+2]		; j = j - 1
	DEC A
	MOV [SP+2], A

	JMP while

endwhile:		

	MOV A,[SP+2]		; A[j] = x
	ADD A,D
	MOV [A], C

	MOV A,[SP+1]		; i = i + 1
	INC A
	MOV [SP+1],A
	
	JMP for

sortend:
	
	; rebalance SP to avoid crash 
	ADD SP, 2
	RET
