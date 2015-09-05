; Sorting via insertion-sort
; see https://en.wikipedia.org/wiki/Insertion_sort
	
	CALL sort		; sort list
	
	MOV D, 232		; offset for display
	MOV A, lastname	; location of sorted elements
	ADD A, 7
	MOV C, 8		; print eight characters

print:

	MOV B,[A]		; display one-character at a time
	MOV [D],B
	
	INC D			; move on to next character
	DEC A			; switch to INC A and remove ADD,7
					; to change sort order ascending/descending
	DEC C			
	JNZ print
	
end:
	HLT

lastname: DB "LASTNAME"

sort:
	SUB SP, 2		; allocate 2 variables on the stack
	MOV [SP+1], 1	; i
	MOV [SP+2], 0	; j

	; for (i = 1; i < length(A); i++)
for:
	
	MOV D, lastname		; sort in place
	
	MOV A, [SP+1]		; i < 8 ?
	CMP A, 8		
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