; -----------------------------------------------------------------------------
; RevStr:        Reverse text
; UPDATED:       06/09/2015
; IN:            Buff, EAX containg the bytes read
; RETURNS:       address of reverse string in ECX
; MODIFIES:	     Buff
; DESCRIPTION:   This procedure reverse the text given to it.

SECTION .bss			; Section containg uninitialized data

SECTION .data			; Section containing initialized data

SECTION .text			; Section containing program code

	global RevStr		; Linker entry point
	extern Buff

RevStr:

	push ebx
	push ecx
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
	; and eax,1		; get odd byte

	; notice the below line removes the added by from
	; the front of the buffer if it was odd
	; as earlier in the program we added and extra byte
	; to even off the buffer if it was odd
	; lea ecx,[Buff+eax]	; copy buff offset into ecx

	pop esi
	pop edx
	pop ecx
	pop ebx

	ret
