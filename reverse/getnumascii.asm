
[SECTION .text]

global _start:

_start:

  ;mov eax,3       ; sys_read
  ;mov ebx,0       ; file descriptor stdin
  ;mov ecx,TXTIN   ; file pointer
  ;mov edx,TXTLEN  ; specify length of string
  ;int 0x80        ; make kernel sys_call

  mov eax,INNUM   ; copy hex number to EAX
  cmp eax,0x03E8   ; check if number is greater than 1ooo
  jge ErrMsg      ; give error and exit

  cmp eax,0x0A    ; compare to 1
  jl  find_1      ; find one
  cmp eax,0x64    ; compare to 100
  jl  find_10     ; find tens

  xor ebx,ebx     ; initialize EBX

find_100:

  sub eax,0x64    ; subtract 100 from number
  add ebx,1       ; add one to EBX
  cmp eax,0x64    ; compare to 100
  jge find_100      ; jump to find digit in tens decimal place

  mov ecx,[NUM+ebx]
  mov [ASCIINUM],ecx

  cmp eax,0x0A
  jl find_1

  xor ebx,ebx

find_10:

  sub eax,0x0A    ; subtract 100 from number
  add ebx,1       ; add one to EBX
  cmp eax,0x0A    ; compare to 100
  jge find_10     ; jump to find digit in tens decimal place

  mov ecx,[NUM+ebx]
  mov [ASCIINUM+1],ecx

find_1:

  mov ecx,[NUM+eax]
  mov [ASCIINUM+2],ecx

  mov eax,4       ; sys_write
  mov ebx,1       ; file descriptor
  mov ecx,TXTIN   ; file pointer
  mov edx,TXTLEN  ; length of string
  int 0x80        ; make kernel sys_call

  jmp Done

ErrMsg:
  mov eax,4       ; sys_write
  mov ebx,1       ; file descriptor
  mov ecx,ErrBigNum ; file pointer
  mov edx,ErrBigLen ; length of string
  int 0x80          ; make kernel sys_call

Done:
  mov eax,1       ; sys_exit
  mov ebx,0       ; return code
  int 0x80        ; make kernel sys_call

[SECTION .data]
  ErrBigNum  db "Number is greater than or equals to 1000",10
  ErrBigLen equ:$-ErrBigNum
  NUM db 30,31,32,33,34,35,36,37,38,39
  INNUM db 3C       ; input number
[SECTION .bss]
  ASCIINUM resb 3   ; reserve bytes for input
