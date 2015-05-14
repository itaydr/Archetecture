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

;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------

duplicate:
	;; Function duplicate:
	;	args: 	[ebp+8]	 - pointer to num A
	;	return:	eax - pointer to new allocated num B which is a duplication of num A
		
	; part 1 - first chain, check if need to malloc ecx struct
	push ebp
	mov ebp, esp
	
	sub esp, 4 			; temp variable (will hold first in chain)
	mov dword [ebp-4], 0		; temp = 0
	
	cmp dword [ebp+8], 0			; sanity check
	jz .done
	
	; malloc struct and call duplicate helper
	push 5
	call malloc
	add esp, 4
	
	mov [ebp-4], eax		; temp = malloc(5)
	mov ecx, eax			; ecx = eax (=temp)
	mov eax, [ebp+8]		; temp = 0
	
	push ecx
	push eax
	call duplicate_rec
	add esp, 8
.done:
	mov eax, [ebp-4]
	
	add esp ,4
	pop ebp
	ret

duplicate_rec:
	;; Function duplicate:
	;	args: 	[ebp+8]	 	- pointer to num A
	;	args: 	[ebp+12]	- pointer to allocated struct for num B
	;	return:	None
	
	push ebp
	mov ebp, esp
	
	mov eax, [ebp+8]	;arg1
	mov ebx, [ebp+12]	;arg2
	
	xor edx,edx
	mov dl, [eax]
	mov [ebx], dl	; copy value
	
	cmp dword [eax+1], 0
	jz .finishCopy
	
	push 5
	call malloc
	add esp, 4
	
	mov ebx, [ebp+12]	; reload ebx
	mov [ebx+1], eax	; set new pointer
	mov eax, [ebp+8]	; reload eax
	
	; advance pointers
	mov eax, [eax+1]
	mov ebx, [ebx+1]
	
	push ebx
	push eax
	call duplicate_rec
	add esp, 8
	jmp .duplicate_rec_ret
.finishCopy:
	mov dword [ebx+1], 0
.duplicate_rec_ret:
	pop ebp
	ret
	
;------------------------------------------------------------------------------------------------------------------------------------------------------------------------