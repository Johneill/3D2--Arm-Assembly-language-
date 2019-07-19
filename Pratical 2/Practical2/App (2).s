	AREA	Practical2, CODE, READONLY
	IMPORT	main
	EXPORT	start

start

IO1DIR	EQU	0xE0028018
IO1SET	EQU	0xE0028014
IO1CLR	EQU	0xE002801C

	ldr	r1,=IO1DIR
	ldr	r2,=0x000f0000	;select P1.19--P1.16
	str	r2,[r1]		;make them outputs
	ldr	r1,=IO1SET
	str	r2,[r1]		;set them to turn the LEDs off
	ldr	r2,=IO1CLR
; r1 points to the SET register
; r2 points to the CLEAR register

	ldr	r5,=0x0	; end when the mask reaches this value
	ldr r0,  = TestNo
	LDR r3, [r0], #1
	LDR r7 ,=0xFFFFFFFF
	MOV r10, #0x0
	
	CMP r3, #0x0
	BGE loop100
	MUL r3, r7, r3
loop100


	;FOR THE 1,000,000,000S//////////////////////////////////////
	LDR r8, =0x3B9ACA00
	
	CMP r3, r8
	BLT loop28
	ADD r10, r10, #0x1
loop29	add R5,R5,#0x1
	SUB R3,R3,r8
	CMP r3, #0x0
	BGE loop30
	add r3,r3,r8
    SUB R5, R5, #0x1
	b LEAVE10
loop30
	B loop29
loop28
LEAVE10
	MOV r5,r5, lsl #4


	;FOR THE 100,000,000S//////////////////////////////////////
	LDR r8, =0x5F5E100

	CMP r3, r8
	BLT loop25
	ADD r10, r10, #0x1
loop26	add R5,R5,#0x1
	SUB R3,R3,r8
	CMP r3, #0x0
	BGE loop27
	add r3,r3,r8
    SUB R5, R5, #0x1
	b LEAVE9
loop27
	B loop26
loop25
LEAVE9
	MOV r5,r5, lsl #4

	;FOR THE 10,000,000S//////////////////////////////////////
	LDR r8, =0x989680

	CMP r3, r8
	BLT loop22
	ADD r10, r10, #0x1
loop23	add R5,R5,#0x1
	SUB R3,R3,r8
	CMP r3, #0x0
	BGE loop24
	add r3,r3,r8
    SUB R5, R5, #0x1
	b LEAVE8
loop24
	B loop23
loop22
LEAVE8
	MOV r5,r5, lsl #4


	;FOR THE 1,000,000S//////////////////////////////////////
	LDR r8, =0xF4240

	CMP r3, r8
	BLT loop19
	ADD r10, r10, #0x1
loop20	add R5,R5,#0x1
	SUB R3,R3,r8
	CMP r3, #0x0
	BGE loop21
	add r3,r3,r8
    SUB R5, R5, #0x1
	B LEAVE7
loop21
	B loop20
loop19
LEAVE7
	MOV r5,r5, lsl #4
	

	;FOR THE 100,000S//////////////////////////////////////
	LDR r8, =0x186A0

	CMP r3, r8
	BLT loop16
	ADD r10, r10, #0x1
loop17	add R5,R5,#0x1
	SUB R3,R3,r8
	CMP r3, #0x0
	BGE loop18
	add r3,r3,r8
    SUB R5, R5, #0x1
	B LEAVE6
loop18
	B loop17
loop16
LEAVE6
	MOV r5,r5, lsl #4


	;FOR THE 10,000S//////////////////////////////////////
	LDR r8, =0x2710

	CMP r3, r8
	BLT loop13
	ADD r10, r10, #0x1
loop14	add R5,R5,#0x1
	SUB R3,R3,r8
	CMP r3, #0x0
	BGE loop15
	add r3,r3,r8
    SUB R5, R5, #0x1
	b LEAVE5
loop15
	B loop14
loop13
LEAVE5
	MOV r5,r5, lsl #4


	;FOR THE 1,000S//////////////////////////////////////
	CMP r3, #0X3E8

	BLT loop10
	ADD r10, r10, #0x1
loop11	add R5,R5,#0x1
	SUB R3,R3,#0x3E8
	CMP r3, #0x0
	BGE loop12
	add r3,r3,#0x3E8
    SUB R5, R5, #0x1
	b LEAVE4
loop12
	B loop11
loop10
LEAVE4
	MOV r5,r5, lsl #4


	;FOR THE 100S//////////////////////////////////////
	CMP r3, #0x64

	BLT loop7
	ADD r10, r10, #0x1
loop8	add R5,R5,#0x1
	SUB R3,R3,#0x64
	CMP r3, #0x0
	BGE loop9
	add r3,r3,#0x64
    SUB R5, R5, #0x1
	b LEAVE3
loop9
	B loop8
loop7
LEAVE3
	MOV r5,r5, lsl #4
	

	;FOR THE TENS//////////////////////////////////////
	CMP r3, #0xA

	BLT loop4
	ADD r10, r10, #0x1
loop5	add R5,R5,#0x1
	SUB R3,R3,#0xa
	CMP r3, #0x0
	BGE loop6
	add r3,r3,#0xA
    SUB R5, R5, #0x1
	b LEAVE2
loop6
	B loop5
loop4
LEAVE2
	MOV r5,r5, lsl #4
	
	;FOR THE UNITS///////////////////////////////////////////////
	CMP r3, #0x1

	BLT loop1
	ADD r10, r10, #0x1
loop2	add R5,R5,#0x1
	SUB R3,R3,#0x1
	CMP r3, #0x0
	BGE loop3
	add r3,r3,#0x1
    SUB R5, R5, #0x1
	B LEAVE1
loop3
	B loop2
loop1
LEAVE1
	
	MOV r11, r10
	;Get Individual Bit
	MOV r8, r5
	ldr r0,  = TestNo
	LDR r3, [r0], #1
	
loop31	MOV r9, r8, LSR #4
	MOV r9, r9, LSL #4
	SUB r9, r8, r9
	MOV r8, r8, LSR #4
	SUB r10, #0x1
	
	;For minus
	CMP r3, #0x0
	BGE loop101
	ldr	r6,=0x00010000	; light P1.16.
	str	r6,[r2]	   	; clear the bit -> turn on the LED
	mov	r6,r6,lsl #2
	str	r6,[r2]	   	; clear the bit -> turn on the LED
	mov	r6,r6,lsl #1 ;
	str	r6,[r2]	   	; clear the bit -> turn on the LED

	MOV r3, #0x1
	B skipplus
loop101
	
	;For the plus
	CMP r3, #0x1
	BEQ skipplus
	
skipplus
	
	
	;For the 0
	CMP r9, #0x0
	BNE Skip0
	B Skip
Skip0
	;For the 1
	CMP r9, #0x1
	BNE Skip1
	B Skip
Skip1
	;For the 2
	CMP r9, #0x2
	BNE Skip2
	ldr	r6,=0x00010000	; light P1.16.
	mov	r6,r6,lsl #2 ;
	str	r6,[r2]	   	; clear the bit -> turn on the LED
	B Skip
Skip2
	;For the 3
	CMP r9, #0x3
	BNE Skip3
	ldr	r6,=0x00010000	; light P1.16.
	mov	r6,r6,lsl #2 ;
	str	r6,[r2]	   	; clear the bit -> turn on the LED
	mov	r6,r6,lsl #3 ;
	str	r6,[r2]	   	; clear the bit -> turn on the LED
	B Skip
Skip3
	;For the 4
	CMP r9, #0x4
	BNE Skip4
	B Skip
Skip4
	;For the 5
	CMP r9, #0x5
	BNE Skip5
	B Skip
Skip5
	;For the 6
	CMP r9, #0x6
	BNE Skip6
	B Skip
Skip6
	;For the 7
	CMP r9, #0x7
	BNE Skip7
	B Skip
Skip7
	;For the 8
	CMP r9, #0x8
	BNE Skip8
	ldr	r6,=0x00010000	; light P1.16.
	str	r6,[r2]	   	; clear the bit -> turn on the LED
	B Skip
Skip8
	;For the 9
	CMP r9, #0x09
	BNE Skip9
	B Skip
Skip9
Skip	
	CMP r10, #0x0
	BNE skip
	MOV r10, r11
	MOV r8, r5
	ldr r0,  = TestNo
	LDR r3, [r0], #1
skip

	ldr	r4,=24000000
dloop	subs	r4,r4,#1
	bne	dloop
	ldr	r6,=0x00010000	; light P1.16.
	str	r6,[r1]	   	; clear the bit -> turn off the LED
	mov	r6,r6,lsl #1 ;
	str	r6,[r1]	   	; clear the bit -> turn off the LED
	mov	r6,r6,lsl #1 ;
	str	r6,[r1]	   	; clear the bit -> turn off the LED
	mov	r6,r6,lsl #1 ;
	str	r6,[r1]	   	; clear the bit -> turn off the LED
	ldr	r4,=24000000
dloop2	subs	r4,r4,#1
	bne	dloop2
	B loop31

stop	B	stop
TestNo	DCD 832
	END	


	;;For the 1
	;CMP r9, #0x1
	;BNE Skip1
	;ldr	r6,=0x00010000	; light P1.16.
	;mov	r6,r6,lsl #3 ;
	;str	r6,[r2]	   	; clear the bit -> turn on the LED
	;B Skip
;Skip1
	;;For the 2
	;CMP r9, #0x2
	;BNE Skip2
	;ldr	r6,=0x00010000	; light P1.16.
	;mov	r6,r6,lsl #2 ;
	;str	r6,[r2]	   	; clear the bit -> turn on the LED
	;B Skip
;Skip2
	;;For the 3
	;CMP r9, #0x3
	;BNE Skip3
	;ldr	r6,=0x00010000	; light P1.16.
	;mov	r6,r6,lsl #2 ;
	;str	r6,[r2]	   	; clear the bit -> turn on the LED
	;mov	r6,r6,lsl #3 ;
	;str	r6,[r2]	   	; clear the bit -> turn on the LED
	;B Skip
;Skip3
	;;For the 4
	;CMP r9, #0x4
	;BNE Skip4
	;ldr	r6,=0x00010000	; light P1.16.
	;mov	r6,r6,lsl #1 ;
	;str	r6,[r2]	   	; clear the bit -> turn on the LED
	;B Skip
;Skip4
	;;For the 5
	;CMP r9, #0x5
	;BNE Skip5
	;ldr	r6,=0x00010000	; light P1.16.
	;mov	r6,r6,lsl #1 ;
	;str	r6,[r2]	   	; clear the bit -> turn on the LED
	;mov	r6,r6,lsl #3 ;
	;str	r6,[r2]	   	; clear the bit -> turn on the LED
	;B Skip
;Skip5
	;;For the 6
	;CMP r9, #0x6
	;BNE Skip6
	;ldr	r6,=0x00010000	; light P1.16.
	;mov	r6,r6,lsl #1 ;
	;str	r6,[r2]	   	; clear the bit -> turn on the LED
	;mov	r6,r6,lsl #2 ;
	;str	r6,[r2]	   	; clear the bit -> turn on the LED
	;B Skip
;Skip6
	;;For the 7
	;CMP r9, #0x7
	;BNE Skip7
	;ldr	r6,=0x00010000	; light P1.16.
	;mov	r6,r6,lsl #1 ;
	;str	r6,[r2]	   	; clear the bit -> turn on the LED
	;mov	r6,r6,lsl #2 ;
	;str	r6,[r2]	   	; clear the bit -> turn on the LED
	;mov	r6,r6,lsl #3 ;
	;str	r6,[r2]	   	; clear the bit -> turn on the LED
	;B Skip
;Skip7
	;;For the 8
	;CMP r9, #0x8
	;BNE Skip8
	;ldr	r6,=0x00010000	; light P1.16.
	;str	r6,[r2]	   	; clear the bit -> turn on the LED
	;B Skip
;Skip8
	;;For the 9
	;CMP r9, #0x09
	;BNE Skip9
	;ldr	r6,=0x00010000	; light P1.16.
	;str	r6,[r2]	   	; clear the bit -> turn on the LED
	;mov	r6,r6,lsl #3 ;
	;str	r6,[r2]	   	; clear the bit -> turn on the LED
	;B Skip
;Skip9
	
	;CMP r10, #0x0
	;BNE Skip
	;MOV r8, r5
;Skip
	;ldr	r4,=24000000
;dloop3	subs	r4,r4,#1
	;bne	dloop3

	;ldr	r6,=0x00010000	; light P1.16.
	;str	r6,[r1]	  	; clear the bit -> turn off the LED
	;mov	r6,r6,lsl #1
	;str	r6,[r1]	  	; clear the bit -> turn off the LED
	;mov	r6,r6,lsl #1
	;str	r6,[r1]	  	; clear the bit -> turn off the LED
	;mov	r6,r6,lsl #1
	;str	r6,[r1]	  	; clear the bit -> turn off the LED



	;B loop31
	
;stop	B	stop
;TestNo	DCD -328
	;END	