; Rotate demo (ROR, ROL)

	MOV A, [num]
	CALL .ror
	CALL .rol
	
	CALL .rol
	CALL .ror
	
	HLT

; Rotate right
;
; Input: A = number
;
; Output: ROR A, 1
;
ror:
	
	MOV B, A
	; rotate by shifting right once
	SHR A, 1
	; check bit 0
	AND B, 1
	JZ .rend
	; copy bit 0 into bit 7
	OR A, 0x80

.rend:	
	
	RET

; Rotate left
;
; Input: A = number
;
; Output: ROL A, 1
;
.rol:
	
	MOV B, A
	; rotate by shifting left once
	SHL A, 1
	; check bit 7
	AND B, 0x80
	JZ .lend
	; copy bit 7 into bit 0
	OR A, 1

.lend:

	RET
	
num:
	; input: 10000001b
	DB 0x81