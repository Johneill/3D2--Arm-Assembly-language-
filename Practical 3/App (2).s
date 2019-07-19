	AREA	AsmTemplate, CODE, READONLY
	IMPORT	main

	EXPORT	start
start

IO1DIR	EQU	0xE0028018
IO1SET	EQU	0xE0028014
IO1CLR	EQU	0xE002801C
IO1PIN 	EQU 0xE0028010
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;NOTE this program uses r0 as the return register for the press subroutine
;This program uses r10 as the number to be displayed on the leds
;r10 is the input to the updatedisp subroutine
;r9 will be used to store the numebr of operations and nubers committed to memory 
;r9 will be the size of the stack 
;r12 will be used to store the calculations stack pointer
;The results subroutine outputs to the r10 register so there are no commands needed between results and updatedisp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	ldr	r1,=IO1DIR
	ldr	r2,=0x000f0000	;select P1.19--P1.16
	str	r2,[r1]		;make them outputs
	
	ldr	r1,=IO1SET
	str	r2,[r1]		;set them to turn the LEDs off
	ldr	r2,=IO1CLR
	
	ldr r3,=IO1PIN 	; set r3 as the read pins registery
	ldr r4,[r3] 	; read the pins into r4
	
; r1 points to the SET register
; r2 points to the CLEAR register
; r3 points to the IO1PIN register
	ldr r9,=0x0 	;there is nothing in the calculati0ns stack just yet
	ldr r5, =0x0  	;set our inital number to be equal to zero 
	ldr r12, =STK_TOP	;set the stack pointer
	mov r10,r5
	bl updatedisp		;start our display
;################################################################
;The input number block
;################################################################
inum	
	mov r10,r5 	 ;mov the digit from our working register into r10
	bl updatedisp
inumnoupdate	
	bl press
	mov r10,r5 	 ;mov the digit from our working register into r10
	bl updatedisp
	movs r0,r0,lsl #1	;we'll shift the neagtive bit out of r0 and catch it in carry
	bcs negativer0		;then we'll branch sowe have to do fewer consequtive checks
	mov r0,r0,lsr #1	; shift her back for simpicity's sake
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;Increase number
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	mov r6,#0x14 	;check if there's a 20 hiding in r0
	cmp r0,r6 
	bne skipincrease	; p1.20 is our "increase numeber" button
	cmp r5, #0x9		;; r5 will represent literally what is output to the leds			
	bne not1001 		;; because of this it will be a circular 4 bit signed number where the leftmore bit represents a niegative sign
	ldr r5,=0x0			;; If we are at minus 1 (1001) then we loop to zero (0000)
	b inum				;; after we perform our operation we return to the top of the program
not1001
	cmp r5,#0x9
	blt	les1001		
	sub r5,r5,#1 	;; if we have a negative number then we decrease it to be closer to 1000 (which is also our zero)
	b inum
les1001
	add r5,r5,#1	; if none of these conditions are met then the number is positive so we just add normally
	b inum
skipincrease
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;decrease number
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	mov r6,#0x15	;check for 21
	cmp r0,r6
	bne skipdecrease	;p1.21 is out decrease number button
	cmp r5,#0x0
	bne not0000
	ldr r5,=0x9
	b inum
not0000	
	cmp r5,#0x8
	blt les1000
	add r5,r5,#1
	b inum
les1000
	sub r5,r5,#1
	b inum
skipdecrease
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;Calculation input
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	mov r6, #0x16	;check for 22
	cmp r0,r6
	beq addition	; adtion is found in the calculation block
	
	mov r6, #0x017 	;check for 23
	cmp r0,r6
	beq subtraction	;subtraction is in the calculations block
	
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;Long press
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
negativer0	;; in this section we're dealing with longpress situations
;; we don't actually do anything with long press p1.20 or p1.21 so we don't check for them
	mov r0,r0,lsr#1 ;shift it back 
	mov r6, #0x16	;check for 22
	cmp r0,r6
	bne notbackspace
	;; backspace will remove the last command and number from the memory stack
	ldr r6,=0x0
	cmp r9,#0
	beq	emptystack
	str r6, [r12],#4	;replae the last operator on the stack and then increment
	str	r6,[r12],#4		;store zero on the stack
	sub r9,#2			;decrease our stack size
	bl results
	bl updatedisp
	b inumnoupdate		
emptystack
	b inum
notbackspace	
	mov r6, #0x17 	;check for 23
	cmp r0,r6
	bne notclear
	;; clear will remove all numbers and operators from the memory stack 
	ldr r6,=0x0
wloop1	
	cmp r9,#0
	beq break1
	str r6,[r12],#4
	str	r6,[r12],#4
	sub r9,#2
	b wloop1
break1
	bl results
	bl updatedisp
	b inumnoupdate	
notclear
	b inum

;##########################################################
;The input calculations block
;##########################################################
icalc

addition
	str r5, [r12,#-4]!	;sub then push
	ldr r5,=0x0
	add r9,r9,#1		;increment stack fullness
	ldr r6,=0xf0 		;this is our addition symbol
	str r6,[r12,#-4]!
	add r9,r9,#1
	bl results
	bl updatedisp
	b inumnoupdate
	
subtraction
	str r5,[r12,#-4]!	;sub then push
	ldr r5,=0x0			;reset our working number
	add r9,r9,#1
	ldr r6,=0xa0 		;this is our subtraction symbol
	str r6,[r12,#-4]!
	add r9,r9,#1
	bl results
	bl updatedisp
	b inumnoupdate

stop	B	stop
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		
;; Here we write our press subroutine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;[A^] [B\] [C+] [D-]
;[20] [21] [22] [23]
press	
	STMFD sp!, {r1-r5,lr} ;;save the used registers and the link register
	ldr r0,=0x0 
activity	
	ldr r3, =IO1PIN ; setting our pin register again just in case 
	ldr r4, [r3] 	;loading our pin data in
	ldr r2, =0x00F00000 
	and r4,r4,r2 	; anding to locate our useful bits 
	cmp r4, r2 		;comparing our bits to see if there are any pressed buttons
	beq activity 	;if the bits are equal then there are currently no pressed buttons so we return to polling	
	mov r0, r4 ;move our data into r0 for processing
	ldr r1, =300000	; Start a counter for a second , ish 
	;; Mess with this number for longer or shorter long press timing 
timer	
	ldr r5, [r3] 	;load our pin data again
	and r5,r5, r2
	cmp r5, r4 
	bne short 		; if the data is not equal then the button has been released before the timer
	subs r1,r1, #1 	;sub for our counter
	bne timer
short
	;Now we'll process r0 according to the value in r1,
	; if r1 is equal to 0 then we have a long press, otherwise it is a shortpress
	ldr r2, =0x00E00000 ; load the p1.23 bit
	cmp r2,r0 ;compare
	bne not23
	ldr r0, =0x14			;load 23 ito r0
not23
	ldr r2, =0x00D00000 ; load the p1.22 bit
	cmp r2,r0 
	bne not22
	ldr r0, =0x15
not22 
	ldr r2, =0x00B00000 ; load the p1.21 bit
	cmp r2,r0
	bne not21
	ldr r0, =0x16
not21
	ldr r2, =0x00700000 ; load the p1.20 bit
	cmp r2, r0
	bne not20
	ldr r0,=0x17
not20
	cmp r1, #0 			;we check if the timer has reached zero, if so it's a long button press
	bne notlong
	ldr r2, =0x80000000	; place a minus zero in r2
	orr r0,r0,r2		; mkae r0 negative 
notlong	
	LDMFD sp!, {r1-r5,pc} 	; load everything back again 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;The update the display subroutine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;This routine will display the 4 bit number present in r10 on th leds p1.16 to p1.19
updatedisp
	STMFD sp!, {r1-r5,lr}
	ldr	r1,=IO1SET
	ldr	r2,=IO1CLR
	; r1 points to the SET register
	; r2 points to the CLEAR register
	
	;;Here we will flip digits of r10 as the leds on the board are backwards compared to their register
	ldr r5,=0x0
	ldr r3,=0x00010000		;set the mask
	mov r4, r10, lsl#13		; move the bit of r10 we need to the right spot
	and r3,r3,r4			;and it out
	orr r5,r5,r3			; or it into r5
	ldr r3,=0x00020000
	mov r4,r10,lsl#15
	and r3,r3,r4
	orr r5,r5,r3	
	ldr r3,=0x00040000
	mov r4,r10,lsl#17
	and r3,r3,r4
	orr r5,r5,r3	
	ldr r3,=0x00080000
	mov r4,r10,lsl#19
	and r3,r3,r4
	orr r5,r5,r3
	ldr r3, =0x000f0000		;select our leds
	str r3,[r1]				;switch them off
	str r5,[r2]				; turn on the bits lised in r5
	LDMFD sp!, {r1-r5,pc}	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Here we write our results subroutine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;The basic concept around this arithmetic is we check our sign bits, separate out our 3 magnitude digits 
;Then we perform different opperations on our magiutude digits and correct it back to 4bit signed depending our original sign bits
results
	STMFD sp!, {r1-r8,lr}
	
	ldr r1, =0xe0 ;We will store our operations in r1 and this is a nop to start with
	ldr r2, =0x0; This is our running total and will be output to r10
	ldr r3, =0x0 ;this will be where we store our working number
	ldr r4, =0x0		; This will be our counter as we are accessing this info abnormally
	ldr r5, =STK_TOP
	sub r5,r5,#4		;the actual stk_top location is empty, so we offset by one before starting
	
wloop
	cmp r4,r9
	bge break	; check if our count has reached the full data
	ldr r3, [r5],#-4 	;load the first digit
	;here we will decode the logic in r1 and perform it on 
	cmp r1, #0xe0	;our n-op
	beq nope
	;++++++++++++++++++++++++++++++++++++ADDITION ARITHMETIC++++++++++++++++++++++++++++++++
	cmp r1,#0xf0 	;our addition symbol
	bne noad
	ldr r6, =0x08	;load a mask for bit checking
	and r7,r6,r3	;mask
	and r8,r6,r2	;mask
	eor r7,r8,r7 	;compare whether signs are different or the same
	cmp r7,r6
	beq difsignadd
	ldr r6,=0x07 	;mask off the 3 non sign digits
	and r7,r6,r2	; 3 digits of the running total
	and r8,r6,r3	;3 digits of the working number
	add r7,r7,r8	;sum the 3 digits
	ldr r6,=0x08	;figure out whetehr the numbers were postive or negative
	and r8,r6,r2	;both numbers have the sam sign so we only need to do this once
	orr r8,r8,r7	;pull the sign into the sum of the 3 non sign digits
	mov r2,r8		;mov our result to the running total ; this number may need some processing to become a 
	b finished

difsignadd	
	ldr r6,=0x08	;mask sign
	and r7,r6,r2	
	cmp r6,r7		;is r2 the negaitve one (if not then r3 is the negative one, we know the yhave different signs
	beq r2negadd
	ldr r6,=0x07	;mask
	and r7,r6,r2
	and r8,r6,r3
	sub r3,r7,r8	;it is assumed then here that r3 is the negative one 
	
	cmp r8,r7
	ble	noflip1
	ldr r6,=0x07
	eor r7,r3,r6 	;flip our digits
	add r7,r7,#1	;add one
	ldr r6, =0x08
	orr r7,r6		;add our negative sign back in 
	mov r2,r7
	b finished		; leave after our job is done
noflip1
	mov r2,r7		;if r3 is less then r2 then our result is not negative so there's no flipping and adding	
	b finished			
r2negadd
	ldr r6,=0x07	;mask
	and r7,r6,r2	
	and r8,r6,r3
	sub r3,r8,r7	; it is assumed here that r2 is negative
	cmp r7,r8
	ble noflip2
	ldr r6,=0x07
	eor r7,r3,r6 	;flip our digits
	add r7,r7,#1	;add one
	ldr r6, =0x08
	orr r7,r6		;add our negative sign back in 
	mov r2,r7
	b finished			
	
noflip2	
	mov r2,r7		;if r2 is less than r3 then our output is positive. no flips no adds
	b finished
noad	
	;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	;----------------------------------------SUBTRACTION ARITHMATIC------------------------------------------------
	cmp r1,#0xa0 	;our subtraction symbol
	bne nosub
	ldr r6, =0x08	;load a mask for bit checking
	and r7,r6,r3	;mask
	and r8,r6,r2	;mask
	eor r7,r8,r7 	;compare whether signs are different or the same
	cmp r7,r6
	beq difsignsub
	ldr r6,=0x07 	;mask off the 3 non sign digits
	and r7,r6,r2	; 3 digits of the running total
	and r8,r6,r3	;3 digits of the working number
	sub r7,r7,r8 	;subtract working number from running total
	cmp r7,#0xf0	;check if our output is has overflowed or not
	bhi overflow
	ldr r6,=0x08
	and r8,r3,r6	;check if we're working with two negatives or two positves
	cmp r8,r6
	beq	twonegsubno
	mov r2,r7		;if both are postive and we've not overflowed then the ouput is done porcessing	
	b finished
twonegsubno	
	ldr r6,=0x08	;if both are negative and we have not overflowed then we simply place the negative sign bit
	orr r7,r6,r7
	mov r2,r7		
	b finished
overflow
	ldr r6,=0x08
	and r8,r3,r6	;check if we're working with two negatives or two positves
	cmp r8,r6
	beq	twonegsubov
	ldr r6,=0x0f		;if both are postive and we've overflowed then we must flip the output add one to it	
	eor r7,r7,r6
	add r7,r7,#1
	ldr r6,=0x08 				;since we've overflowed we have a negative number and must set the sign bit as such		
	orr r7,r7,r6
	mov r2,r7					; set the output and run 
	b finished
twonegsubov
	ldr r6,=0x0f				; if both are negative and we have overflowed then we must flip, add one and set the siign bit to be positive
	eor r7,r7,r6
	add r7,r7,#1
	mov r2,r7
	b finished

difsignsub	
	;; if the signs are different then we jus ttake the magnitude its, add them and set the sign to be the same as the r2 sign
	ldr r6,=0x07
	and r7,r6,r2
	and r8,r6,r3
	add r7,r7,r8
	ldr r6,=0x08
	and r8,r6,r2	;pull the sign bit from r2
	orr r7,r8,r7	;set it in r7
	mov r2,r7
	
nosub
	b finished
	;--------------------------------------------------------------------------------------------------------------
nope
	mov r2,r3		; if no op was performed we load r3 into our running total
finished	
	ldr r1, [r5],#-4 	;load the next operator into r1
	add r4,r4,#2		;we are performing two pops from the stack
	b wloop
break	
	mov r10,r2			;mov into our ouput register
	LDMFD sp!, {r1-r8,pc}
	
;=================================================
;Memory Location for calculations
;=================================================
STK_SZ EQU 0x20 	;32 byte stack
	;We will be storing our numbers and operations in 1 byte each
	; This will be a descending stack , so subtract before pushing, add after popping
	;since we want to be able to access this memory as both a stack and a queue we will store the size of the
	;of the stack in r9 
	
	AREA 	CalculationsStack, DATA,READWRITE
CLCSTK SPACE STK_SZ
STK_TOP
	
	END