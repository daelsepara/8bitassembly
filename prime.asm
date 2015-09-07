; program to compute for primes between [1, 1000]
; Lacks display. 

start:

 CALL prime

end:

 HLT

count: DB 1
sumL: DB 2
sumH: DB 0
sumD: DB 0
lsb: DB 0x03
msb:  DB 0x00
divL: DB 0
divH: DB 0

main:
 
 ; main loop - check if we have reached 1000
 MOV A, [lsb]
 CMP A,0xE8
 JNZ .nz1
 MOV A, [msb]
 CMP A,0x03
 JZ end

.nz1:

 INC A
 MOV [lsb], A
 JNC .nc1
 MOV A,[msb]
 INC A
 MOV [msb],A

.nc1:
 
 MOV A,[lsb]
 
 ; do not process even numbers
 AND A, 1
 JZ main
 
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
 
.nz2: 

 ; start at number - 1 
 MOV A, [divL]
 DEC A
 MOV [divL], A
 JNC .nc2
 
 ; handle carry
 MOV B, [divH]
 DEC B
 MOV [divH], C

.nc2:
 
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
 
 ; division main loop
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
 CMP C, 1
 JNZ main
 OR B,B
 JNZ main

.nz3:
 
 ; prime number found
 MOV A,[count]
 INC A
 MOV [count], A
 
 ; compute running sum
 MOV A,[lsb]
 MOV D,[msb]
 MOV B,[sumL]
 MOV C,[sumH]
 
 ADD A,B
 MOV [sumL],A
 JNC .nc3
 
 ; handle overflow
 INC C

.nc3:
 
 ADD C,D
 MOV [sumH],C
 JNC main
 
 ; handle overflow
 MOV A, [sumD]
 INC A
 MOV [sumD], A
 
 JMP main
