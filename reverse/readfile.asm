; Source file: 		readfile.asm
; Executable file: 	readfile
; Version:		1.0
; Create Date:		07/01/2015
; Last updated Date:	07/02/2015
; Author:		king kunta
; Description:		This program opens a file and prints
;			contents to screen using glibc functions
;
; Build using these command
;	nasm -f elf -g -F stabs readfile.asm
;	gcc readfile.o -o readfile
[SECTION .data]		; initialized data section
      OpenCode db "r",0	; code past to foopen()
      ErrorMsg db "An error occurred ...yup yup it did.",10,0 ; error message
[SECTION .bss]		; uninitialized data section
      TXTFLEN EQU 1024	; Define lenth of line of text data
      TxtLine resb TXTFLEN	; Reserver space for disk-based

[SECTION .text]		; section contianing program code

;; glibc functions imports
extern fopen
extern fgets
extern printf
extern fclose

global main		; entry point

main:
      nop
      push ebp		         ; store EBP on stack
      mov ebp,esp	         ; store ESP value in EBP
      push ebx		         ; store EBX on stack
      push esi		         ; store ESI on stack
      push edi		         ; store EDI on stack

;; Everything before this is boiler plate use it in all ordinary apps

    mov edi,dword [ebp+12] 	; store address of args table in EDI
    push OpenCode		        ; push address of open-for-read code "r"
    push dword [edi+4]		  ; push first arg (filename) on the stack
    call fopen			        ; Attempt to open the file for reading
    add esp,8			          ; stack cleanup: 2 parms x 4 bytes = 8
    cmp eax,0			          ; compare 0 to EAX
    je ErrMsg			          ; jump if error
    mov ebx,eax			        ; save file handle

    ; read file
    push ebx			; push file handle on stack
    push dword TXTFLEN		; limit line length of text read
    push TxtLine		; push address of text file buffer
    call fgets			; read a line of text
    add esp,12			; clean up stack

    xor eax,eax			; saerching for 0 so clear AL to 0

    mov ecx,00000400h		; limit search to 1024
    mov edi,TxtLine		; copy address of buffer into EDI
    mov edx,edi			; copy start address into EDX
    cld				; set serach direction to up-memory
    repne scasb			; sarch for null (0 char) in string at edi
    mov byte [edi-1],10		; insert a newline character to the end of buffer
    push TxtLine		; push address of help line on the stack
    call printf			; prints contains to stdo
    add esp,4			; cleanup stack

    push ebx			; push file handle on stack
    call fclose			; close teh file whose handle is on the stack
    add esp,4			; clean up stack

    jmp Done			; jump to skip error message

ErrMsg:

    push ErrorMsg		; push error message on stack to be printed
    call printf			; print to screen
    add esp,4			; clean stack

Done:

    ;; The following is biler plate as well

    pop edi			; pop EDI from stack
    pop esi			; pop ESI from stack
    pop ebx			; pop EBX from stack
    mov esp,ebp			; copy value in EBP to ESP
    pop ebp			; pop EBP from stack
    ret
