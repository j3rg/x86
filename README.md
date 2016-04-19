# x86
Programs written in x86 architecture for Linux OS

Programs:

1. reverse

The reverse program is used to simply reverse contents in a file.

Build (I'll create a make file soon so to make building quicker)

nasm -f elf -g -F stabs reverse.asm
nasm -f elf -g -F stabs reverselib.asm
gcc -o reverse.o reverselib.o -o reverse

Run in the following manner:

./reverse <inputfile> <outputfile>

2. timer

As this is my first time using git to manage my project
let me practice.
