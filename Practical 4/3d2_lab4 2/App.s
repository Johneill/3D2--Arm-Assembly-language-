 ; Definitions  -- references to 'UM' are to the User Manual.

; Timer Stuff -- UM, Table 173

T0	equ	0xE0004000		; Timer 0 Base Address
T1	equ	0xE0008000

IR	equ	0			; Add this to a timer's base address to get actual register address
TCR	equ	4
MCR	equ	0x14
MR0	equ	0x18

TimerCommandReset	equ	2
TimerCommandRun	equ	1
TimerModeResetAndInterrupt	equ	3
TimerResetTimer0Interrupt	equ	1
TimerResetAllInterrupts	equ	0xFF

; VIC Stuff -- UM, Table 41
VIC	equ	0xFFFFF000		; VIC Base Address
IntEnable	equ	0x10
VectAddr	equ	0x30
VectAddr0	equ	0x100
VectCtrl0	equ	0x200

Timer0ChannelNumber	equ	4	; UM, Table 63
Timer0Mask	equ	1<<Timer0ChannelNumber	; UM, Table 63
IRQslot_en	equ	5		; UM, Table 58
	
IO0PIN equ 0xE0028000
IO0SET equ 0xE0028004
IO0DIR equ 0xE0028008
IO0CLR EQU 0xE002800C
	
blue  EQU 0X00040000 ;position 18
green  EQU 0X00200000 ;position 21
red    EQU 0X00020000 ;position 17

	AREA	InitialisationAndMain, CODE, READONLY
	IMPORT	main

; (c) Mike Brady, 2014 -- 2019.

	EXPORT	start
start
; initialisation code

; Initialise the VIC
	ldr	r0,=VIC			; looking at you, VIC!

	ldr	r1,=irqhan
	str	r1,[r0,#VectAddr0] 	; associate our interrupt handler with Vectored Interrupt 0

	mov	r1,#Timer0ChannelNumber+(1<<IRQslot_en)
	str	r1,[r0,#VectCtrl0] 	; make Timer 0 interrupts the source of Vectored Interrupt 0

	mov	r1,#Timer0Mask
	str	r1,[r0,#IntEnable]	; enable Timer 0 interrupts to be recognised by the VIC

	mov	r1,#0
	str	r1,[r0,#VectAddr]   	; remove any pending interrupt (may not be needed)

; Initialise Timer 0
	ldr	r0,=T0			; looking at you, Timer 0!

	mov	r1,#TimerCommandReset
	str	r1,[r0,#TCR]

	mov	r1,#TimerResetAllInterrupts
	str	r1,[r0,#IR]

	ldr	r1,=(14745600/200)-1	 ; 5 ms = 1/200 second
	str	r1,[r0,#MR0]

	mov	r1,#TimerModeResetAndInterrupt
	str	r1,[r0,#MCR]

	mov	r1,#TimerCommandRun
	str	r1,[r0,#TCR]

;from here, initialisation is finished, so it should be the main body of the main program
	ldr R10,=IO0PIN
	ldr R2,[R10]
	ldr R6,=IO0DIR 	;SELECTING PINS FOR OUTPUT
	ldr R5,=0x260000 ; PIN 17,18 & 21
	str R5,[R6]
	ldr R6,=IO0SET 	;TURNING ALL PINS OFF
	str R5,[R6]
	ldr R5,=IO0CLR 	;TURNING SELECTED PINS ON
	ldr R4,=0x260000
	
	ldr r3, =tick
	ldr	r12, [r3]
	ADD r12,r12,#200
	
loop2
	ldr	r9, [r3]
	CMP r9,r12
	BCS	endloop2	;Unsigned >=
	B	loop2
	
endloop2
	ADD r12,r12,#200
	
	ldr	r7, =turn_on
	ldr	r8, [r7]
	
	CMP r8,#6 ;;compare value in r8 and 6 if the same enter the loop
	BNE skip1
	MOV	r8, #2
	str	r8, [r7]
	ldr R2,=blue ;;this section will turn in ther blue light
	str	R4,[R6]
	str	R2,[R5]
	b skip3
skip1
	CMP R8,#4 ;compare value in r8 and 4 if the same enter the loop
	BNE skip2
	MOV	r8, #6
	str	r8, [r7]
	ldr R2,=green ;this section will turn in ther green light
	str	R4,[R6]
	str	R2,[R5]
	b skip3
skip2
	CMP R8,#2 ;compare value in r8 and 2 if the same enter the loop
	BNE skip3
	MOV	r8, #4
	str	r8, [r7]
	ldr R2,=red ; this section will turn in ther red light
	str	R4,[R6]
	str	R2,[R5]
skip3
	B loop2

wloop	b	wloop  		; branch always
;main program execution will never drop below the statement above.

	AREA	InterruptStuff, CODE, READONLY
irqhan	sub	lr,lr,#4
	stmfd	sp!,{r0-r1, r5, r11, lr}	; the lr will be restored to the pc aka saving where it came from!!!
	
	;this is the body of the interrupt handler

;here you'd put the unique part of your interrupt handler
;all the other stuff is "housekeeping" to save registers and acknowledge interrupts
	ldr 	r5, =tick ;load tick
	ldr		r11, [r5]
	add 	r11, r11, #1 ; add one to tick
	str		r11, [r5]; store tick back in memory

;this is where we stop the timer from making the interrupt request to the VIC
;i.e. we 'acknowledge' the interrupt
	ldr	r0,=T0
	mov	r1,#TimerResetTimer0Interrupt
	str	r1,[r0,#IR]	   	; remove MR0 interrupt request from timer

;here we stop the VIC from making the interrupt request to the CPU:
	ldr	r0,=VIC
	mov	r1,#0
	str	r1,[r0,#VectAddr]	; reset VIC

	ldmfd	sp!,{r0-r1, r5, r11, pc}^	; return from interrupt, restoring pc from lr
				; and also restoring the CPSR and going back to same place where it came from
		
	AREA	memory, DATA, READWRITE
tick	DCD 0
turn_on	DCD 2
	END

