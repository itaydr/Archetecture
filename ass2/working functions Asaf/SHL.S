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

;------------------------------------------------------------------------------------------------------------------------------------------------------------------
power_2_y:
	;; Function power_2_y:
	;	args: 	[ebp+8]	 	- pointer to num A
	;	args: 	[ebp+12]	 - pointer to num B
	;	return:	eax - pointer to numA after shl B times
	push ebp
	mov ebp,esp
	
	sub esp, 4				; make room for counter variable
	
	; sannity check [ebp+12] == 0
	mov eax, [ebp+12]
	cmp dword [eax+1], 0
	jnz .sanity_ok
	cmp byte [eax], 0
	jnz .sanity_ok
	jmp .done
	
	; [ebp+12] is not zero. we can work...
.sanity_ok:	
	push RPN_ZERO
	call duplicate
	add esp, 4
	
	mov [ebp-4], eax			; counter variable = currently 0
	
.power_loop:
	push dword [ebp+8]
	call inline_shl
	add esp,4
	
	push RPN_ONE
	push dword [ebp-4]
	call inline_plus
	add esp,8
	
	push dword [ebp-4]
	push dword [ebp+12]
	call compare
	add esp,8
	cmp eax, 0
	jz .power_loop
.done:
	add esp,4
	mov eax, [ebp+8]
	pop ebp
	ret
	
	
inline_shl:
	;; Function inline_shl:
	;	args: 	[ebp+8]	 - pointer to num A
	;	return:	eax - pointer to numA after shl
	
	push ebp
	mov ebp, esp

	mov eax, [ebp+8]	;arg1
	
	push 0			; initial bit to push from right
	push dword [ebp+8]	; num A
	call inline_shl_rec
	add esp,2*4
	mov eax, [ebp+8]
	
	pop ebp
	ret
	
	
inline_shl_rec:
	;; Function plus:
	;	args: 	[ebp+8]	 - pointer to num A
	;			[ebp+12] - 0 / 1 bit to push from right
	;	return:	none
	
	push ebp
	mov ebp, esp
	
;	sub esp, 16
	mov eax, [ebp+8]	;arg1
	
	cmp eax,0
	jz .done

;;;	mov ebx, [ebp+12]	;arg2 - bit to push from right
	
	shl byte [eax], 1
	jc .hasCarry
	mov ebx, 0
	jmp .afterCarry
.hasCarry:
	mov ebx, 1
.afterCarry:
	; change the old bit from previous chain
	mov edx,[ebp+12]
	or byte [eax], dl
	
	cmp dword [eax+1], 0
	jnz .nextEaxAllocated
	cmp ebx, 0
	jz .done
	
	; allocate eax
	push eax
	push ebx
	
	push 5
	call malloc
	add esp,4
	
	mov dword [eax+1],0
	mov byte  [eax],0
	
	mov edx, eax
	pop ebx
	pop eax
	mov [eax+1], edx
.nextEaxAllocated:
	
	push ebx
	push dword [eax+1]
	call inline_shl_rec
	add esp,8
	
.done:
	pop ebp
	ret
	
;----------------------------------------------------------------------------------------------------------------------------------