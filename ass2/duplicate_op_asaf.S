section .bss

section	.rodata
LC0:
	DB	"blaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa", 10, 0	; Format string
X_STRING:
	DB	"%x", 00
CRASH_STRING:
	DB	0x0d, 0x0a, "Crashing because i dont know to exit windows..." ,00

section	.data

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
	
	mov byte [eax],0xBF
	mov dword [eax+1],ebx
	mov byte [ebx],0xAD
	mov dword [ebx+1],ecx
	mov byte [ecx],0xDE
	mov dword [ecx+1],0
	
	push ecx
	push ebx
	push eax
	call duplicate
	add esp,12
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
	push X_STRING
	call printf
	add esp,8
	
.done:
	pop ebp
	ret