section	.rodata
LC0:
	DB	"The result is:  %d", 10, 0	; Format string

section .bss
;LC1:
;	RESB	32

section .text
	align 16
	global calc_func
	extern printf
	extern check

calc_func:
	push	ebp
	mov	ebp, esp	; Entry code - set up ebp and esp
	pusha			; Save registers

	mov ecx, dword [ebp+8]	; Get argument (interger x)

	push ecx
	call check
	add esp,4

	; TODO... the calculation


	push	eax		; Call printf with 2 arguments: pointer to str
	push	LC0		; and pointer to format string.
	call	printf
	add 	esp, 8		; Clean up stack after call



	popa			; Restore registers
	mov	esp, ebp	; Function exit code
	pop	ebp
	ret
