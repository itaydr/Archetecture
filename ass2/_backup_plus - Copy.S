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
	;start of main
	pushad
	push esp
	mov ebp, esp
	
	mov eax, LC0
	mov eax, 0x12345678
	
	sub esp, 12	; 3 variables
	
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
	
	; end of main
returnAddress:
	mov ecx, eax
	
	add esp, 8
	
	pop ebp
	popad
	
	mov ebx,0
	mov eax,1
	int 0x80

	
plus:
	;; Function plus:
		args: 	[ebp+8]	 - pointer to num A
				[ebp+12] - pointer to num B
		return:	eax - pointer to new allocated num or 0 if no such num
		
		; TODO continue
		
	push ebp
	mov ebp, esp
	
	sub esp, 12
	
	mov eax,  [ebp+8]	;arg1
	mov ebx,  [ebp+12]	;arg2
	mov ecx,  [ebp+16]	;arg3
	
	; prepare initial
	mov byte [PLUS_CARRY_FLAG], 0
	
;	; copy to local variables - used in case of malloc
;	mov [ebp-4],   eax
;	mov [ebp-8],   ebx
;	mov [ebp-12],  ecx
	
.plusLoop:	
	;sanity check of to allocate ecx
	cmp eax,0
	jnz .sanityPass
	cmp ebx,0
	jnz .sanityPass
	cmp byte [PLUS_CARRY_FLAG],0
	jnz .sanityPass
	
	jmp .done
	.sanityPass:



	xor edx,edx		;reset edx
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
	
	; malloc - save registers
	mov [ebp-4],   eax
	mov [ebp-8],   ebx
	mov [ebp-12],  ecx
	
	push 5
	call malloc
	add esp, 4
	
	mov ecx, [ebp-12] ;load ecx before malloc
	
	mov ecx, eax
	mov [ecx+1],eax
	mov ecx, [ecx+1]
	
	mov eax, [ebp-4] ;load eax before malloc
	mov ebx, [ebp-8] ;load ebx before malloc
	jmp .plusLoop
	
.done:
	mov dword [ecx+1],0
	
	; free 2 last numbers - load original pointer
	mov eax,  [ebp+8]	;arg1
	push eax
	call freeLinkList
	add esp, 4
	
	mov ebx,  [ebp+12]	;arg2
	push ebx
	call freeLinkList
	add esp, 4
	
	add esp,12 ;clear local variables
	
	pop ebp
	ret
	
	
	
;----------
freeLinkList:
	push ebp
	mov ebp,esp
	cmp dword [ebp+8],0
	jz .freeDone
	mov eax, [ebp+8]
	
	push dword [eax+1] ;prepare next chain
	call freeLinkList
	add esp, 4
	
	; restore prepeare free
	push dword [ebp+8]
	call free
	add esp, 4
	
	.freeDone:
	pop ebp
	ret