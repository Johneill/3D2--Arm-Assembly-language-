Task:

The task is to write a program that implements a calculator using the four LEDs on the ARM Board and the four push-buttons below them. The LEDs are connected to P1.16 to P1.19 and the buttons are connected to P1.20 to P1.23.

Briefly, the idea is that you can enter 4-bit binary numbers using the leftmost two buttons, and you can specify the operations to be performed (Add, Subtract, Clear, Clear All) using the rightmost two buttons.

Initially, the calculator should have a clear display — all LEDs off.

To enter a number n, use the leftmost two buttons. Pressing the leftmost button (“n+”) should increase the number and pressing the second-from-left button (“n-“) should decrease the number.
To add a number, press the second-from-right button (“+”) and then enter the second number.
To subtract a number, press the rightmost button (“-”) and then enter the second number.
When a "+" or a "-" is entered, display the result of the last calculation, if any, until one of the leftmost buttons is pressed. The first press of either of those buttons should clear the display.
To clear the last operation (+ or -) and the number being entered, long-press the second-from-right button. The user can then enter a new operator and a new number and continue.
To clear the entire calculator, long-press the rightmost button.
Numbers should be represented in signed binary, but don’t worry about sign overflow etc.

Mandatory Requirements:
You must write and use a subroutine to read a press or a long press from the keys.
The subroutine must be “well-behaved” in the sense we have discussed in class.
For a regular press, the subroutine must return the index number (20 to 23) of the key that has been pressed in R0.
For a long press, the subroutine must return the negative of the index number (i.e. -20 to -23) of the key in R0.
You must not implement autorepeat on any keys.
