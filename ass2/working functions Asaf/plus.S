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

RPN_ONE:
	DB	01,00,00,00,00

	
section	.data

section .text
;------------------------------------------------------------------------------------------------------------------------------------------------------------------------

inline_plus:
	;; Function plus:
	;	args: 	[ebp+8]	 - pointer to num A
	;			[ebp+12] - pointer to num B
	;	return:	eax - pointer to numA after adding num A and num B
	
	push ebp
	mov ebp, esp

	mov eax, [ebp+8]	;arg1
	mov ebx, [ebp+12]	;arg2
	
	push 0			; initial carry
	push dword [ebp+12]	; num B
	push dword [ebp+8]	; num A
	call inline_plus_rec
	add esp,3*4
	mov eax, [ebp+8]
	
	pop ebp
	ret
	
	
inline_plus_rec:
	;; Function plus:
	;	args: 	[ebp+8]	 - pointer to num A
	;			[ebp+12] - pointer to num B
	;			[ebp+16] - 0 / 1 carry
	;	return:	none
	
	push ebp
	mov ebp, esp
	
	sub esp, 16
	mov dword [ebp-16], 0		;arg4 - new carry - continue flag for first add linitialized to 0
	
	mov eax, [ebp+8]	;arg1
	mov ebx, [ebp+12]	;arg2
	mov ecx, [ebp+16]	;arg3 - carry
	
	add [eax], cl		; add old carry to eax
	jc .setContinueFlag
	mov dword [ebp-16],0
	jmp .finishedOldCarry
.setContinueFlag:
	mov dword [ebp-16],1
.finishedOldCarry:	
	
	xor edx, edx
	mov dl, [ebx]
	add [eax], dl
	jnc .noCarry
.yesCarry:
	cmp dword [eax+1], 0
	jnz .nextEaxAllocated
	; allocate eax
	mov [ebp-4],  eax	; temp_var1
	mov [ebp-8],  ebx	; temp_var2
	mov [ebp-12], ecx	; temp_var3 - carry
	
	push 5
	call malloc
	add esp,4
	
	mov dword [eax+1],0
	mov byte  [eax],0
	
	mov edx, eax
	mov eax, [ebp-4]	; temp_var1
	mov ebx, [ebp-8]	; temp_var2
	mov ecx, [ebp-12]	; temp_var3 - carry
	
	mov [eax+1], edx
.nextEaxAllocated:
	cmp dword [ebx+1],0
	jnz .recursionCallWithNextEbx
	push 0
	push RPN_ONE
	push dword [eax+1]
	call inline_plus_rec
	add esp, 12
	jmp .done
.recursionCallWithNextEbx:
	push 1
	push dword [ebx+1]
	push dword [eax+1]
	call inline_plus_rec
	add esp, 12
	jmp .done

.noCarry:		; no carry on second adding
	cmp dword [ebp-16],0 ; check first carry
	jnz .yesCarry
	
	cmp dword [ebx+1], 0
	jz .done
	
	; [ebx+1] != 0  ==> we need to continue to the next element in chain
	cmp dword [eax+1], 0
	jnz .nextEaxAllocated2
	; allocate eax
	mov [ebp-4],  eax	; temp_var1
	mov [ebp-8],  ebx	; temp_var2
	mov [ebp-12], ecx	; temp_var3 - carry
	
	push 5
	call malloc
	add esp,4
	
	mov dword [eax+1],0
	mov byte  [eax],0
	
	mov edx, eax
	mov eax, [ebp-4]	; temp_var1
	mov ebx, [ebp-8]	; temp_var2
	mov ecx, [ebp-12]	; temp_var3 - carry
	
	mov [eax+1], edx
.nextEaxAllocated2:
	push 0
	push dword [ebx+1]
	push dword [eax+1]
	call inline_plus_rec
	add esp, 12
	jmp .done
.done:
	add esp, 16
	pop ebp
	ret	