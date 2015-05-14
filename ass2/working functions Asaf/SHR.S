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

///////----------------------------------------------------------- power_2_minus_y ---------------------------------------
power_2_minus_y:
	;; Function power_2_minus_y:
	;	args: 	[ebp+8]	 	- pointer to num A
	;	args: 	[ebp+12]	 - pointer to num B
	;	return:	eax - pointer to numA after shr B times
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
	call inline_shr
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
	
	
inline_shr:
	;; Function inline_shr:
	;	args: 	[ebp+8]	 - pointer to num A
	;	return:	eax - pointer to numA after shr
	
	push ebp
	mov ebp, esp

	mov eax, [ebp+8]	;arg1
	
	; sanity check if num A is a single node
	cmp dword [eax+1], 0
	jz .singleNode
	
	push dword [ebp+8]	; num A
	call inline_shr_rec
	add esp,1*4
	mov eax, [ebp+8]
	jmp .done
.singleNode:
	shr byte [eax], 1
.done:
	pop ebp
	ret
	
	
inline_shr_rec:
	;; Function plus:
	;	args: 	[ebp+8]	 - pointer to num A
	;	return:	eax = 1 - need to free pointer, else eax = 0
	
	push ebp
	mov ebp, esp
	
	mov eax, [ebp+8]	;arg1 - current node
	
	mov ebx, [eax+1]	; load next node
	
	shr byte [eax],1	; do the SHR in current node
	
	cmp ebx, 0
	jnz .hasNextNode
	cmp byte [eax], 0
	jz .eaxFlagFree
	mov eax, 0
	jmp .done
.eaxFlagFree:
	mov eax, 1
	jmp .done
.hasNextNode:
	xor ecx, ecx
	mov byte cl, 1
	and cl, [ebx]
	shl cl,7
	or byte [eax],cl
		;; recursive call
	push ebx
	call inline_shr_rec
	add esp,4
		;; check if need to free the next chain
	cmp eax,0
	jz .done
		;; we need to free the next node
	mov eax, [ebp+8]	;arg1 - current node
	push dword [eax+1]
	call free
	add esp,4
	mov eax, [ebp+8]
	mov dword [eax+1],0
	mov eax,0
.done:
	
	pop ebp
	ret

;----------------------------------------------------------------------------------------------------------------------------------