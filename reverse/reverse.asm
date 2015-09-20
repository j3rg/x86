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

global Buff

[SECTION .data]		; initialized data section
      OpenCode db "r",0	; used in fopen()
      WriteCode db "w",0 ; used in fopen()
      ErrorMsg db "An error occurred when opening the file.",10,0 ; error message
      EOF db -1 ; end of file flag
      RdComplete db "End of file"
[SECTION .bss]		; uninitialized data section
      TXTFLEN EQU 1024	; Define lenth of line of text data
      Buff resb TXTFLEN	; Reserver space for disk-based

[SECTION .text]		; section contianing program code

;; glibc functions imports
extern fopen
extern fgets
extern printf
extern fclose
extern fputs
extern strlen

;; custom function import
extern RevStr

global main		; entry point

main:

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
    mov ebx,eax             ; store file handle in EBX
    je ErrMsg			          ; jump if error

ReadBuffer:

    ; read file

    push eax			; push file handle on stack
    push dword TXTFLEN		; limit line length of text read
    push Buff		; push address of text file buffer
    call fgets			; read a line of text
    add esp,12			; clean up stack

    ; close file
    push ebx			; push file handle on stack
    call fclose			; close teh file whose handle is on the stack
    add esp,4			; clean up stack

    ; get size of buffer

    push Buff    ; push address of text file buffer
    call strlen     ; gets the length of the string
    add esp,4       ; clear the stack

    cmp byte [Buff], 0  ; check if end of line
    je EOFmsg           ; display end of line message

    push ecx         ; save value of ECX on stack
    call RevStr      ; call RevStr procedure
    mov esi,ecx      ; save new address of reversed string
    pop ecx          ; restore ECX value from stack

    ;xor eax,eax			; saerching for 0 so clear AL to 0

    ;mov ecx,0x400		; limit search to 1024
    ;mov edi,Buff		; copy address of buffer into EDI
    ;mov edx,edi			; copy start address into EDX

    ; replace null terminator with new line character
    ;cld				; set serach direction to up-memory
    ;repne scasb			; sarch for null (0 char) in string at edi
    ;mov byte [edi-1],10		; insert a newline character to the end of buffer

    push WriteCode		        ; push address of open-for-read code "r"
    push dword [edi+8]		  ; push first arg (filename) on the stack
    call fopen			        ; Attempt to open the file for reading
    add esp,8			          ; stack cleanup: 2 parms x 4 bytes = 8
    cmp eax,0			          ; compare 0 to EAX
    mov ebx,eax             ; copy file handle to EBX
    je ErrMsg			          ; jump if error

    push eax    ; push file handle
    push esi		; push address of reversed string
    call fputs			; prints contains to stdo
    add esp,8			; cleanup stack

    push ebx			; push file handle on stack
    call fclose			; close teh file whose handle is on the stack
    add esp,4			; clean up stack

    jmp Done			; jump to skip error message

EOFmsg:

    push RdComplete ; push EOF message on stack to be printed
    call printf     ; print to screen
    add esp,4       ; clear stack
    jmp Done        ; this is not good assembly programming

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
