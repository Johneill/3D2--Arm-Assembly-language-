The purpose of this lab is to get you to explore two of the building-blocks of operating systems -- threads and schedulers.

Task
The task is to set up a very simple timer-interrupt-driven scheduler that gives equal processor time to two threads. Make the timer interrupt occur every 5 ms. When an interrupt occurs, the interrupt handler should suspend the "current" thread and resume the "other" one.

