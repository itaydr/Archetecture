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
	align 32
	global main
	extern malloc
	extern free
	extern printf
;	extern DebugPrintNumber

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
	
	mov byte [eax],0xFF
	mov dword [eax+1],ecx
	mov byte [ebx],0x1
	mov dword [ebx+1],0
	mov byte [ecx],0xFF
	mov dword [ecx+1],0

	
	push ecx
	push ebx
	push eax
	call inline_plus
	
	; end of main
returnAddress:
	mov ecx, eax
	
	push ecx
	call DebugPrintNumber
	add esp, 4
	
	
	add esp, 8
	
	pop ebp
	popad

	push CRASH_STRING
	call printf
	add esp,4
	
	
	mov ebx,0
	mov eax,1
;	int 0x80	;-	Linux only!!
	xor eax,eax
	mov ah,4Ch
	int 21h

	
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
	
DebugPrintNumber_rec:
	push ebp
	mov ebp,esp
	
	cmp dword [ebp+8], 0
	jz .done
	
	mov eax, [ebp+8]
	mov eax, [eax+1]
	push eax
	call DebugPrintNumber_rec
	add esp,4
	
	mov eax, [ebp+8]
	xor ebx,ebx
	add bl,[eax]
	push ebx
	push X_2_STRING
	call printf
	add esp,8
	
.done:
	pop ebp
	ret