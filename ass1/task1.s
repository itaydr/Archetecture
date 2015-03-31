section	.rodata
LC0:
	DB	"The result is:  %s", 10, 0	; Format string

section .bss
LC1:
	RESB	32

section .text
	align 16
	global my_func
	extern printf

my_func:
	push	ebp
	mov	ebp, esp	; Entry code - set up ebp and esp
	pusha			; Save registers

	mov ecx, dword [ebp+8]	; Get argument (pointer to string)

	mov eax, 0		;	init eax
				; read binary string and set eax to contain the number
START_READ_LOOP:
	cmp byte [ecx],'0'
	je OK_BIN
	cmp byte [ecx],'1'
	je OK_BIN
	jmp FINISHED_READ
OK_BIN:
	shl eax,1
	cmp byte [ecx],'1'
	jne SKIP_OR
	or eax, 1

SKIP_OR:
	inc ecx
	jmp START_READ_LOOP
FINISHED_READ:

;	jmp TEST1
	
				; finished reading the bunary string
				; converting number to hex
	mov ecx,LC1
HEX_LOOP:
	cmp eax,0
	je FINISHED_CONVERT

	mov ebx,eax
	shr ebx, 28

	jmp COMPARE_HEX
DONE_COMPARE_HEX:
	mov byte [ecx], dl
	inc ecx

	shl eax,4
	jmp HEX_LOOP
FINISHED_CONVERT:
	mov byte [ecx], 0
	





;TEST1:
;	push	eax
	push	LC1		; Call printf with 2 arguments: pointer to str
	push	LC0		; and pointer to format string.
	call	printf
	add 	esp, 8		; Clean up stack after call



	popa			; Restore registers
	mov	esp, ebp	; Function exit code
	pop	ebp
	ret

COMPARE_HEX:
	mov edx,'1'
	cmp ebx,1
	je DONE_COMPARE_HEX
	mov edx,'2'
	cmp ebx,2
	je DONE_COMPARE_HEX
	mov edx,'3'
	cmp ebx,3
	je DONE_COMPARE_HEX
	mov edx,'4'
	cmp ebx,4
	je DONE_COMPARE_HEX
	mov edx,'5'
	cmp ebx,5
	je DONE_COMPARE_HEX
	mov edx,'6'
	cmp ebx,6
	je DONE_COMPARE_HEX
	mov edx,'7'
	cmp ebx,7
	je DONE_COMPARE_HEX
	mov edx,'8'
	cmp ebx,8
	je DONE_COMPARE_HEX
	mov edx,'9'
	cmp ebx,9
	je DONE_COMPARE_HEX
	mov edx,'A'
	cmp ebx,10
	je DONE_COMPARE_HEX
	mov edx,'B'
	cmp ebx,11
	je DONE_COMPARE_HEX
	mov edx,'C'
	cmp ebx,12
	je DONE_COMPARE_HEX
	mov edx,'D'
	cmp ebx,13
	je DONE_COMPARE_HEX
	mov edx,'E'
	cmp ebx,14
	je DONE_COMPARE_HEX
	mov edx,'F'
	cmp ebx,15
	je DONE_COMPARE_HEX
	mov edx,'0'
	cmp ebx,0
	je DONE_COMPARE_HEX

