section .bss

section	.rodata
LC0:
	DB	"blaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa", 10, 0	; Format string

section	.data
PLUS_CARRY_FLAG:	DB	0
PLUS_CONTINUE_FLAG:	DB	0

section .text
	align 32
	global main
	extern malloc
	extern free

main:
	mov eax, LC0
	mov eax, 0x12345678
	
	sub esp, 12
	
	push 5
	call malloc
	add esp,4
	mov [ebp-12], eax
	
	push 5
	call malloc
	add esp,4
	mov [ebp-8], eax
	
	push 5
	call malloc
	add esp,4
	mov [ebp-4], eax
	
	mov eax, [ebp-4]
	mov ebx, [ebp-8]
	mov ecx, [ebp-12]
	
	mov byte [eax],0x00
	mov dword [eax+1],0
	mov byte [ebx],0x00
	mov dword [ebx+1],0
	
	push ecx
	push ebx
	push eax
	call plus
	
plus:
	push ebp
	mov ebp, esp
	
	pop eax
	pop ebx
	pop ecx

	push ebx
	push eax
	
.plusStart:	
	mov byte dl,[PLUS_CARRY_FLAG]
	mov byte [PLUS_CARRY_FLAG],0
	mov byte [PLUS_CONTINUE_FLAG],0
	
	cmp eax,0
	jz .afterEax
	mov byte [PLUS_CONTINUE_FLAG],1
	add byte dl,[eax]
	mov eax, [eax+1]
.afterEax:
	JNC .noCarryFirst
	mov byte [PLUS_CARRY_FLAG],1
	mov byte [PLUS_CONTINUE_FLAG],1
.noCarryFirst:

	cmp ebx,0
	jz .afterEbx
	mov byte [PLUS_CONTINUE_FLAG],1
	add byte dl, [ebx]
	mov ebx, [ebx+1]
.afterEbx:
	JNC .noCarrySecond
	mov byte [PLUS_CARRY_FLAG],1
	mov byte [PLUS_CONTINUE_FLAG],1
.noCarrySecond:
	
	mov byte [ecx],dl
	cmp byte [PLUS_CONTINUE_FLAG],0
	jz .done
	
	push eax
	push 5
	call malloc
	mov ecx, eax
	
	mov [ecx+1],eax
	mov ecx, [ecx+1]
	jmp .plusStart
.done:
	mov dword [ecx+1],0
	pop eax
	; free eax
	
	pop ebx
	; free ebx
	
	pop ebp
	ret