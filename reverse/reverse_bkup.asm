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
      ReadCode db "r",0	; used in fopen()
      AppendCode db "w",0 ; used in fopen()
      ErrorMsg db "An error occurred when opening the file.",10,0 ; error message
      EOF db -1 ; end of file flag
      TmpName db "Temp-"
      TmpExt db ".tmp"
[SECTION .bss]		; uninitialized data section
      TXTFLEN EQU 1024	; Define lenth of line of text data
      Buff resb TXTFLEN	; Reserver space for disk-based
      TmpBuff resb TXTFLEN ; Reserver sapce for temp buffer
      TmpFile resb 12 ; name of temporary file
      counter resd 1 ; counter variable
      charcount resd 0 ; char counter
[SECTION .text]		; section contianing program code

;; glibc functions imports
extern fopen
extern getc
extern printf
extern fclose
extern fputs
extern strlen

;; custom function import
extern RevStr
extern GetASCIINum

global main		; entry point

main:

    push ebp		            ; Store EBP on stack
    mov ebp,esp	            ; Store ESP value in EBP
    push ebx		            ; Store EBX on stack
    push esi		            ; Store ESI on stack
    push edi		            ; Store EDI on stack

;; Everything before this is boiler plate use it in all ordinary apps

    mov edi,dword [ebp+12] 	; Store address of args table in EDI
    push ReadCode		        ; Push address of open-for-read code "r"
    push dword [edi+4]		  ; Push first arg (filename) on the stack
    call fopen			        ; Attempt to open the file for reading
    add esp,8			          ; Stack cleanup: 2 parms x 4 bytes = 8
    cmp eax,0			          ; Compare 0 to EAX
    je ErrMsg			          ; Jump if error

ReadBuffer:

    mov ecx, TXTFLEN        ; copy buffer size
    push eax                ; Push file handler for safe-keeping

.readChars:

    ; read file
    push eax                ; Push file handel one stack for safe-keeping

    push eax			          ; Push file handle on stack for getc function call
    call getc			          ; Read a line of text
    add esp,4 			        ; Clean up stack

    ; copy char into buffer
    mov edx,[charcount]     ; move index of string into EDX
    mov byte [Buff+edx],al  ; Copy character to buffer
    inc edx                 ; increment EDX
    mov [charcount],edx     ; copy incremented index into EDX

    pop eax                 ; pop file handler into EAX

    dec ecx                 ; decrement EBX
    jnz .readChars          ; read another character

    push eax                ; Push file handler on stack for safe-keeping

    ; Get size of buffer
    push Buff               ; Push address of text file buffer
    call strlen             ; Gets the length of the string
    add esp,4               ; Clear the stack

    cmp eax,0               ; Check if the length is zero
    je FileDone             ; Display end of line message

    call RevStr             ; Call RevStr procedure
    push ecx                ; Save new address of reversed string on stack

    mov edx,[counter]
    inc edx                 ; Increment count of temporary files
    mov word [counter],edx  ; Copy incremenred value back to counter varible

    mov eax,edx             ; Copy temp file number to EAX for GetASCIINum call
    call GetASCIINum        ; Get number ascii in address stored in ECX

    cld                     ; Clear DF for up-memory Write
    mov esi,ecx             ; Store source string
    lea edi,[TmpFile+4]     ; Store address of temp filename string to continue from
    mov ecx,3               ; Move 3 bytes to move number
    rep movsb               ; Copy string

    ; Determine temporary filename
    cld                     ; Clear DF for up-memory Write
    mov esi,TmpName         ; Load source index with start name of temp file
    mov edi,TmpFile         ; Load destination of temporary file address
    mov ecx,5               ; 5 bytes to move 'Temp-'
    rep movsb               ; Copy string

    cld                     ; Clear DF for up-memory Write
    mov esi,TmpExt          ; Load source index with extention string of temp file
    lea edi,[TmpFile+7]     ; Load destination of temp file address
    mov ecx,4               ; 4 bytes to move '.tmp'
    rep movsb               ; Copy string

    push WriteCode		      ; Push address of open-for-read code "r"
    push TmpFile		        ; Push first arg (filename) on the stack
    call fopen			        ; Attempt to open the file for reading
    add esp,8			          ; Stack cleanup: 2 parms x 4 bytes = 8

    cmp eax,0			          ; Compare 0 to EAX
    je ErrMsg			          ; Jump if error

    mov ebx,eax             ; Copy temporary file handle to EBX

    pop ecx                 ; pop reverse string into ECX

    push eax                ; Push temp file handle
    push ecx		            ; Push address of reversed string
    call fputs			        ; Prints contents to stdo
    add esp,8			          ; Cleanup stack

    push ebx			          ; Push file handle on stack
    call fclose			        ; Close teh file whose handle is on the stack
    add esp,4			          ; Clean up stack

    pop eax                 ; Restore input file handler into EAX

    jmp ReadBuffer          ; Check for more data

FileDone:

    ; Close input file
    pop eax                 ; Restore file handler into EAX
    push eax			          ; Push file handle on stack
    call fclose			        ; Close teh file whose handle is on the stack
    add esp,4			          ; Clean up stack

.openTmpFile:

    mov edx,[counter]       ; Copy the temp file counter into EDX

    mov eax,edx             ; Copy temp file number to EAX for GetASCIINum call
    call GetASCIINum        ; Get number ascii in address stored in ECX

    cld                     ; Clear DF for up-memory Write
    mov esi,ecx             ; Store source string
    lea edi,[TmpFile+4]     ; Store address of temp filename string to continue from
    mov ecx,3               ; Move 3 bytes to move number
    rep movsb               ; Copy string

    ; Determine temporary filename
    cld                     ; Clear DF for up-memory Write
    mov esi,TmpName         ; Load source index with start name of temp file
    mov edi,TmpFile         ; Load destination of temporary file address
    mov ecx,5               ; 5 bytes to move 'Temp-'
    rep movsb               ; Copy string

    push ReadCode           ; Push address of open-for-read code "r"
    push TmpFile            ; Push first arg (filename) on the stack
    call fopen              ; Attempt to open the file for reading
    add esp,8               ; Stack cleanup: 2 parms x 4 bytes = 8

    cmp eax,0               ; Compare 0 to EAX
    je ErrMsg               ; Jump if error

    mov ebx,eax             ; Copy file handle to EBX

    xor edx,edx             ; initialize EDX to zero
    mov [charcount],edx     ; copy zero in EDX to charcount variable

    mov ecx,TXTFLEN         ; copy size into TXTFLEN

    push eax                ; Push temp file on stack for safe-keeping

.readTempChars:

    ; read temp file
    push eax			          ; Push file handle on stack
    call getc			          ; Read a line of text
    add esp,4 			        ; Clean up stack

    mov edx,[charcount]
    mov byte [Buff+edx],al  ; Copy character to buffer
    inc edx                 ; increment EDX

    mov [charcount],edx
    pop eax                 ; pop file handler into EAX
    push eax                ; push file handler on stack

    dec ecx                 ; decrement EBX
    jnz .readTempChars      ; read another character

    ; Finish reading temp file so close the file
    pop eax                 ; Push file handle on stack
    call fclose             ; Close teh file whose handle is on the stack
    add esp,4               ; Clean up stack

    mov edi,dword [ebp+12]  ; Store address of args table in EDI
    push AppedCode          ; Push address of open-for-write code "w"
    push dword [edi+8]      ; Push second arg (filename) on the stack
    call fopen              ; Attempt to open the file for reading
    add esp,8               ; Stack cleanup: 2 parms x 4 bytes = 8
    cmp eax,0               ; Compare 0 to EAX
    je ErrMsg               ; Jump if error

    push eax                ; save output file handler on stack

    push eax                ; Push file handle
    push TmpBuff            ; Push address of string read from tmp file
    call fputs              ; Prints contains to stdo
    add esp,8               ; Cleanup stack

    ; Drecrease temp file count
    mov edx,[counter]       ; Copy the temp file counter into EDX
    dec edx                 ; Decrement count of temporary files
    cmp edx,0               ; Check if is zero or below zero
    jbe Done                ; Jump to Done if zero or below

    mov [counter],edx       ; move value back to counter

ErrMsg:

    push ErrorMsg		        ; Push error message on stack to be printed
    call printf			        ; Print to screen
    add esp,4			          ; Clean stack

Done:

    ; Close input file
    pop eax                 ; Restore file handler into EAX
    push eax                      ; Push file handle on stack
    call fclose                 ; Close teh file whose handle is on the stack
    add esp,4                     ; Clean up stack

    ;; The following is biler plate as well
    pop edi			            ; Pop EDI from stack
    pop esi			            ; Pop ESI from stack
    pop ebx			            ; Pop EBX from stack
    mov esp,ebp			        ; Copy value in EBP to ESP
    pop ebp			            ; Pop EBP from stack
    ret
