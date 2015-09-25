SECTION .bss			; Section containg uninitialized data
	ASCIINUM resb 4   ; reserve bytes for input
SECTION .data			; Section containing initialized data
	ErrBigNum:  db "Number is greater than or equals to 1000",10
 	ErrBigLen: equ $-ErrBigNum
 	NUM: db 0x30,0x31,0x32,0x33,0x34,0x35,0x36,0x37,0x38,0x39
 	;INNUM db 0x3C       ; input number
SECTION .text			; Section containing program code

	global RevStr		; Declare function as global
	global GetASCIINum	; Declare function as global

	extern Buff

; -----------------------------------------------------------------------------
; RevStr:        Reverse text
; UPDATED:       06/09/2015
; IN:            Buff, EAX containg the bytes read
; RETURNS:       address of reverse string in ECX
; MODIFIES:	     Buff
; DESCRIPTION:   This procedure reverse the text given to it.
;------------------------------------------------------------------------------

RevStr:

	push ebx
	push edx
	push esi

; This initialize the counter
	mov ecx,eax				; store bytes read in ECX to use as counter
	xor esi,esi       ; initialize ESI to zero to be used later

; This part is necessary to find out if the bytes are odd
	mov edx,eax				; copy to EDX for odd byte checking
	shr edx,1								; check if odd bytes
	jnc .pushBytes					; jump if even bytes

; If bytes read are odd make even by adding one. This is necessary for tracking
; the counter correctly
	add ecx,1							  ; add one to amount of bytes read

.pushBytes:     					; push bytes on stack in reverse
	mov bx, word [Buff+esi] ; copy 2 bytes from buffer offset into ax
	xchg bh,bl							; exchange halves
	push bx									; push last 2 bytes at end of buffer
	add esi,2								; add 2 to edi for traversing the buffer
	sub ecx,2								; subtract 2 from counter to know when buffer is empty
	jnz .pushBytes					; Jump to read next dword if buffer not empty

.popBytes:

	pop word [Buff+ecx]			; pop word into buffer overwritting contents
	add ecx,2								; add 2 to eax to know amount of bytes in buffer
	sub esi,2								; decrease counter by 2 to know when stack is empty
	jnz .popBytes						; jump to PushBytes if stack is not empty

	; Use mask to mark start of buffer
	and eax,1		; get odd byte

	; notice the below line removes the added by from
	; the front of the buffer if it was odd
	; as earlier in the program we added and extra byte
	; to even off the buffer if it was odd
	lea ecx,[Buff+eax]	; copy buff offset into ecx

	pop esi
	pop edx
	pop ebx

	ret

; -----------------------------------------------------------------------------
; GetASCIINum:   Return the ascii equivalent of a hex digit under 1000
; UPDATED:       25/09/2015
; IN:            EAX containg the hex number
; RETURNS:       Ascii value in register ECX
; MODIFIES:	     Nothing
; DESCRIPTION:   Return the ascii equivalent of a hex digit under 1000
;				 with padding zeros.
;------------------------------------------------------------------------------

GetASCIINum:
  
 ; save values of registers on stack before executing
  push ebx

  cmp eax,0x03E8   ; check if number is greater than 1ooo
  jge Done         ; give error and exit


  ; this line is necessary for zero padding
  mov dword [ASCIINUM],0x00303030

  cmp eax,0x0A    ; compare to 1
  jl  .find_1     ; find one
  cmp eax,0x64    ; compare to 100
  jl  .find_10    ; find tens

  xor ebx,ebx     ; initialize EBX

.find_100:

  sub eax,0x64    ; subtract 100 from number
  add ebx,0x01       ; add one to EBX
  cmp eax,0x64    ; compare to 100
  jge .find_100   ; jump to find digit in tens decimal place

  mov ecx,[NUM+ebx]
  mov [ASCIINUM],cl

  cmp eax,0x0A
  jl .find_1

  xor ebx,ebx

.find_10:

  sub eax,0x0A    ; subtract 100 from number
  add ebx,0x01       ; add one to EBX
  cmp eax,0x0A    ; compare to 100
  jge .find_10    ; jump to find digit in tens decimal place

  mov ecx,[NUM+ebx]
  mov [ASCIINUM+1],cl

.find_1:

  mov ecx,[NUM+eax]
  mov [ASCIINUM+2],cl

  mov ecx, [NUM]

Done:
  
  pop ebx

  ret