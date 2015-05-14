section .bss

section	.rodata
LC0:
	DB	"blaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa", 10, 0	; Format string
	
X_2_STRING:
	DB	"%02x", 00
X_1_STRING:
	DB	"%x", 00

CRASH_STRING:
	DB	0x0d, 0x0a, "Crashing because i dont know to exit windows..." ,00

RPN_ZERO:
	DB	00,00,00,00,00
RPN_ONE:
	DB	01,00,00,00,00

	
section	.data
PLUS_CARRY_FLAG:	DB	0
PLUS_CONTINUE_FLAG:	DB	0

section .text

;------------------------------------------------------------------------------------------------------
compare:
	;; Function compare:
	;	args: 	[ebp+8]	 	- pointer to num A
	;	args: 	[ebp+12]	- pointer to num B
	;	return:	eax - True (1) or False (0)
		
	push ebp
	mov ebp, esp
	
	cmp dword [ebp+8], 0			; check end of Num A
	jz .arg1ZeroCheckArg2
	cmp dword [ebp+12], 0			; check end of Num B
	jz .false
	
	mov ebx, [ebp+12]
	mov cl, [ebx]
	mov ebx, [ebp+8]
	mov bl, [ebx]
	
	cmp cl, bl
	jnz .false
	
	mov ebx, [ebp+12]
	mov ebx, [ebx+1]
	push ebx
	mov ebx, [ebp+8]
	mov ebx, [ebx+1]
	push ebx
	call compare
	add esp,8
	jmp .done
.arg1ZeroCheckArg2:
	cmp dword [ebp+12], 0			; check end of Num B
	jz .true
	jmp .false
.true:
	mov eax, 1
	jmp .done
.false:
	mov eax, 0
	jmp .done
.done:
	pop ebp
	ret

;------------------------------------------------------------------------------------------------------