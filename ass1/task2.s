section	.rodata
LC0:
	DB	"The result is:  %d", 10, 0	; Format string

LC1:
	DB	"x is out of range", 10, 0	; Format string
	
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
	
	; if legal, eax = 1, else, eax = 0
	cmp eax, 0
	je NOT_LEGAL
	
	; ecx is legal, do calculation..
	mov eax, 0
	cmp ecx,0
	je PRINT_ECX
	
	mov ebx, ecx
	mov eax, 1
	
GO1_LOOP:
	cmp ebx,0
	je GO1_DONE
	
	shl eax,1
	
	dec ebx
	
	jmp GO1_LOOP
GO1_DONE:
	
	mov edx, eax
	shr edx, 16
	and eax, 0x0000FFFF
	
	div ecx
	
	
	
	
	; TODO... the calculation


PRINT_ECX:
	
	push	eax		; Call printf with 2 arguments: pointer to str
	push	LC0		; and pointer to format string.
	call	printf
	add 	esp, 8		; Clean up stack after call
	
	jmp DONE

NOT_LEGAL:
	push	LC1		; and pointer to format string.
	call	printf
	add 	esp, 4		; Clean up stack after call

DONE:

	popa			; Restore registers
	mov	esp, ebp	; Function exit code
	pop	ebp
	ret
