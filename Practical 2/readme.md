Task
The task is to write a program to convert a signed binary 32-bit integer to its decimal form and to display it on the ARM Board. The difficulty is that the ARM boards have no built-in display, so you'll have to use the four LEDs instead.


Use the four LEDs to display the least significant four bits of each decimal digit's ASCII code, in turn, for a brief period -- about a second. To denote a binary "1", turn the corresponding LED on. To denote a binary "0", turn the corresponding LED off. Look at the sample assembly project to figure out how to do that.


The display sequence should begin with a blank display for about a second. It may be followed with a code for a "+" or "-" sign -- say "1010" or "1011" respectively -- and then by the four-bit code for each digit. You'll need to use a special code for the decimal digit "0" or it will be invisible -- use "1111" for it. The output sequence should be repeated endlessly.

 
Example
For example, let's say the number is 0x00000419. In decimal, this is 1049, so, the display should go like this:


"0000" → "1010" → "0001" → "1111" → "0100" → "1001" → "0000" … and so on, repeating endlessly.


Much of this can be developed using the KEIL SDK and its built-in emulator and debugger.


The number to be displayed should be stored in a DCD somewhere, so that, for demonstration purposes, it will be easy for you to change the number quickly, reassemble the program and reflash it to the ARM Board. Do not "hard wire" a fixed number into your program.

