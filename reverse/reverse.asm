; Executable name: reverse.asm
; Version	 : 1.0
; Created date	 : 5/17/2015
; Last update	 : 7/16/2015
; Author	 : Jorgen Ordonez
; Description	 : A simple program in assembly for Linux, using NASM 2.10.01,
;   demonstrating simple test file I/O (through redirection) for reading an
;   input file to buffer in blocks of 1024 bytes, placing the blocks on the
;   by reversing one word of the block and pushing it on the stack then popping
;   it back into the buffer, this reverse the file. Finally right out the reverse
;   block to file. This is done for each block so to reverse the file
;
; Run it this way
;   reverse > (output file) < (input file)
;
; Build using these commands:
;  nasm -f elf -g -F stabs reverse.asm
;  ld -o reverse reverse.o
;
SECTION .bss			; Section containg uninitialized data

	BUFFLEN equ 1024	; Length of buffer
	Buff: resb BUFFLEN	; Text buffer itself

SECTION .data			; Section containing initialized data

SECTION .text			; Section containing program code

	global _start		; Linker entry point
	
_start:				
	nop			; This no-op keeps gdb happy...
	
; Read a buffer full of text from stdin:
Read:

	mov eax,3		; Specify sys_read call
	mov ebx,0		; Specif File Descriptor 0: Standard Input
	mov ecx,Buff		; Pass offset of buffer to read to
	mov edx,BUFFLEN		; Pass number of bytes to read at one pass
	int 80h			; Call sys_read to fill buffer
	cmp eax,0		; If eax=0, sys_read reached EOF on stdin
	je Done			; Jump to end progarm for EOF
	
; This initialize the counter
	mov ebp,eax		; store bytes read in ebp to use as counter
; This part is necessary to find out if the bytes are odd
	mov esi,eax		; copy to esi for odd byte checking
	shr esi,1		; check if odd bytes
	jnc PushBytes		; jump if even bytes
	
; If bytes read are odd make even by adding one. This is necessary for tracking the counter
; correctly
	add ebp,1			; add one to amount of bytes read

PushBytes:
	mov bx, word [Buff+edi] ; copy 2 bytes from buffer offset into ax
	xchg bh,bl		; exchange halves
	push bx			; push last 2 bytes at end of buffer
	add edi,2		; add 2 to edi for traversing the buffer
	sub ebp,2		; subtract 2 from counter to know when buffer is empty
	jnz PushBytes		; Jump to read next dword if buffer not empty
	
	xor edx,edx		; set ecx to 0
	
PopBytes:
	
	pop word [Buff+edx]	; pop word into buffer
	add edx,2		; add 2 to eax to know amount of bytes in buffer
	sub edi,2		; decrease counter by 2 to know when stack is empty
	jnz PopBytes		; jump to PushBytes if stack is not empty
	
	xor edi,edi		; zero out edi
	
; Use mask to mark start of buffer
	mov edx,eax		; copy bytes read to edi for safe keeping
	and eax,1		; get odd byte
	
	;mov ecx,Buff		; copy buff offset into ecx
	lea ecx,[Buff+eax]	; copy buff offset into ecx
	add ecx,eax		; set offset of buffer
	;mov edx,edi		; calculate actual bytes in buffer
	
; write out the bytes from buffer to file
	mov eax,4		; Specif write_sys call
	mov ebx,1		; Specify File Descriptor 1: Standard output
; the location and amount of characters to write were already assigned 
; hence no need to set the address in ecx and the amount in edx
	int 80h			; Make sys_write kernel call
	jmp Read		; jump to read more block if any
      
; All done! Let's end this party:
Done:

	mov eax,1		; Code for Exit Syscall
	mov ebx,0		; Return code of zero
	int 80h			; Make sys_exit kernel call
	
	nop			; makes the debugger happy