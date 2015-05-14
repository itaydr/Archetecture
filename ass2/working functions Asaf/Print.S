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
;------------------------------------------------------------------------------------------------------------------------------
DebugPrintNumber:
	push ebp
	mov ebp,esp
	
	cmp dword [ebp+8], 0
	jz .done
	
	mov eax, [ebp+8]
	mov eax, [eax+1]
	push eax
	call DebugPrintNumber
	add esp,4
	
	mov eax, [ebp+8]
	xor ebx,ebx
	add bl,[eax]
	push ebx
	cmp dword [eax+1], 0
	jz .printEndOfChain
	push X_2_STRING
	jmp .printfNumber
.printEndOfChain:
	push X_1_STRING
.printfNumber:
	call printf
	add esp,8
	
.done:
	pop ebp
	ret
;----------------------------------------------------------------