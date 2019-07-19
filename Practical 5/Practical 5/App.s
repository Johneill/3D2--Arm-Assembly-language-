		AREA	InitialisationAndMain, CODE, READONLY
		IMPORT	main
		EXPORT	start
start

 ;Setup GPIO
IO1DIR 	equ		0xE0028018
IO1SET	equ		0xE0028014
IO1CLR	equ		0xE002801C
IO1PIN 	equ 	0xE0028010

		ldr		r1,	=IO1DIR
		ldr		r2,=0x000f0000				;select P1.19--P1.16
		str		r2,[r1]						;make them outputs
		ldr		r1,=IO1SET
		str		r2,[r1]						;set them to turn the LEDs off
		ldr		r2,=IO1CLR

; Setup User Mode
Mode_USR equ	0x10

; Definitions  -- references to 'UM' are to the User Manual.
; Timer Stuff -- UM, Table 173
T0		equ 	0xE0004000					; Timer 0 Base Address
T1		equ 	0xE0008000
IR		equ 	0						
TCR		equ 	4						
MCR		equ 	0x14						
MR0		equ 	0x18

TimerCommandReset equ 2
TimerCommandRun	equ 1
TimerModeResetAndInterrupt equ 3
TimerResetTimer0Interrupt equ 1
TimerResetAllInterrupts	equ 0xFF

; VIC Stuff -- UM, Table 41
VIC		equ 0xFFFFF000				
IntEnable	equ 0x10					
VectAddr	equ 0x30					
VectAddr0	equ 0x100
VectCtrl0	equ 0x200

Timer0ChannelNumber equ	4					; UM, Table 63
Timer0Mask	equ 1 <<Timer0ChannelNumber		; UM, Table 63
IRQslot_en	equ 5							; UM, Table 58

; Initialisation code
; Initialise the VIC
		ldr 	r0, =VIC					; looking at you, VIC!

		ldr 	r1, =irqhan
		str 	r1, [r0, #VectAddr0] 		; associate our interrupt handler with Vectored Interrupt 0

		mov 	r1, #Timer0ChannelNumber+(1<<IRQslot_en)
		str 	r1, [r0, #VectCtrl0] 		; make Timer 0 interrupts the source of Vectored Interrupt 0

		mov 	r1, #Timer0Mask
		str 	r1, [r0, #IntEnable]		; enable Timer 0 interrupts to be recognised by the VIC

		mov 	r1, #0
		str 	r1, [r0, #VectAddr]   		; remove any pending interrupt (may not be needed)

; Initialise Timer 0
		ldr 	r0, =T0						; looking at you, Timer 0!

		mov 	r1, #TimerCommandReset
		str 	r1, [r0, #TCR]

		mov 	r1, #TimerResetAllInterrupts
		str 	r1, [r0, #IR]

		ldr 	r1, =(14745600/200) - 1	 	; 5 ms = 1/200 second
		str 	r1, [r0, #MR0]

		mov 	r1, #TimerModeResetAndInterrupt
		str 	r1, [r0, #MCR]

		mov 	r1, #TimerCommandRun
		str 	r1, [r0, #TCR]
		
; Setup Stack for each CurrentlyRunning
		ldr 	r0, =0
		ldr 	r1, =0
		ldr 	r2, =0
		ldr 	r3, =0
		ldr 	r4, =0
		ldr 	r5, =0
		ldr 	r6, =0
		ldr 	r7, =0
		ldr		r8, =0
		ldr 	r9, =ColorsTop
		
		ldr 	r10, =ColorsStack
		ldr 	r11, [r10]
		stmfd 	r11!, {r0-r8, r9}
		str 	r11, [r10]
		
		ldr 	r9, =SequenceTop

		ldr 	r10, =SequenceStack
		ldr 	r11, [r10]
		stmfd 	r11!, {r0-r8, r9}
		str 	r11, [r10]
		
		msr		cpsr_c, #Mode_USR
loop	b	 	loop



ColorsTop
;GPIO Setup
IO0DIR	equ		0xE0028008
IO0SET	equ		0xE0028004
IO0CLR	equ		0xE002800C
	
		ldr 	r0, =IO0DIR
		ldr 	r1, =0x00260000				; Select P0.17, P0.18, P0.21
		str 	r1, [r0]					; Make them outputs
		ldr 	r0, =IO0SET
		str 	r1, [r0]					; Set them to turn the LEDs off
		ldr 	r1, =IO0CLR
		
; From here, initialisation is finished, so it should be the main body of the main program
		ldr 	r5, =timer
		ldr 	r7, [r5]
		add		r7, r7, #(1000/5)
wh1		ldr 	r2, =leds
		mov 	r4, #8
		ldr 	r3, [r2], #4
		str 	r3, [r1]
dowh1	ldr 	r5, =timer
		ldr 	r6, [r5]
		cmp 	r6, r7
		bcc 	endif4
		mov		r7, r6
		add		r7, r7, #(1000/5)
		str 	r6, [r5]
		sub 	r4, r4, #1
		str 	r3, [r0]
		ldr 	r3, [r2], #4
		str 	r3, [r1]
endif4	cmp 	r4, #0
		bne 	dowh1
		b 		wh1	
; Main program execution will never drop below the statement above.



SequenceTop
;Setup GPIO
	ldr	r1,=IO1DIR
	ldr	r2,=0x000f0000	;select P1.19--P1.16
	str	r2,[r1]		;make them outputs
	ldr	r1,=IO1SET
	str	r2,[r1]		;set them to turn the LEDs off
	ldr	r2,=IO1CLR
; r1 points to the SET register
; r2 points to the CLEAR register

	ldr	r5,=0x00100000	; end when the mask reaches this value
wloop	ldr	r3,=0x00010000	; start with P1.16.
floop	str	r3,[r2]	   	; clear the bit -> turn on the LED

;delay for about a half second
	ldr	r4,=1000000 ;this is the value that needs changed, cant see flash at 5000
dloop	subs	r4,r4,#1
	bne	dloop

	str	r3,[r1]		;set the bit -> turn off the LED
	mov	r3,r3,lsl #1	;shift up to next bit. P1.16 -> P1.17 etc.
	cmp	r3,r5
	bne	floop
	b	wloop
stop	B	stop



		AREA	InterruptStuff, CODE, READONLY	
irqhan	sub		lr, lr, #4				
; this is the body of the interrupt handler
		
; here you'd put the unique part of your interrupt handler
; all the other stuff is "housekeeping" to save registers and acknowledge interrupts

; Increment Timer for LED CurrentlyRunning
		ldr		r9, =timer
		ldr		r10, [r9]
		add		r10, r10, #1
		str		r10, [r9]
		cmp		r10, #1
		beq		else00
		
; Swap CurrentlyRunning and Load in Registers and Address of Other CurrentlyRunning
		ldr		r9, =CurrentlyRunning
		ldr		r10, [r9]
		cmp		r10, #0
		bne		else11
		ldr		r11, =ColorsStack
		ldr 	r12, [r11]
		stmfd 	r12!, {r0-r8, lr}
		str 	r12, [r11]
		ldr		r11, =SequenceStack
		ldr 	r12, [r11]
		ldmfd 	r12!, {r0-r8, lr}
		str 	r12, [r11]
		ldr		sp, [r11]
		stmfd	sp!, {lr}					; the lr will be restored to the pc
		ldr		r10, =1
		b 		endif11
else11	ldr		r11, =SequenceStack
		ldr 	r12, [r11]
		stmfd 	r12!, {r0-r8, lr}
		str 	r12, [r11]
		ldr		r11, =ColorsStack
		ldr 	r12, [r11]
		ldmfd 	r12!, {r0-r8, lr}
		str 	r12, [r11]
		ldr		sp, [r11]
		stmfd	sp!, {lr}					; the lr will be restored to the pc			
		ldr 	r10, =0
endif11	str		r10, [r9]
		b		endif00
else00	ldr		r9, =CurrentlyRunning
		ldr 	r10, =1
		str		r10, [r9]
		ldr		r11, =SequenceStack
		ldr 	r12, [r11]
		ldmfd 	r12!, {r0-r8, lr}
		str 	r12, [r11]
		ldr		sp, [r11]
		stmfd	sp!, {lr}					; the lr will be restored to the pc	
endif00		
		
; this is where we stop the timer from making the interrupt request to the VIC
; i.e. we 'acknowledge' the interrupt

		ldr 	r9, =T0
		mov 	r10, #TimerResetTimer0Interrupt
		str 	r10, [r9, #IR]	   			; remove MR0 interrupt request from timer

; here we stop the VIC from making the interrupt request to the CPU:
		ldr 	r9, =VIC
		mov 	r10, #0
		str 	r10, [r9, #VectAddr]		; reset VIC
		ldmfd  	sp!, {pc}^			
		


		AREA 	memory, DATA, READWRITE
leds	dcd		0x00000000
		dcd 	0x00020000
		dcd 	0x00200000
		dcd 	0x00040000
		dcd 	0x00220000
		dcd 	0x00060000
		dcd 	0x00240000
		dcd 	0x00260000
CurrentlyRunning	dcd 	0x00000000
ColorsStack 	dcd 	0x40002048
SequenceStack	dcd 	0x40001024
timer	dcd 	0x00000000



		END