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
	
	mov ebx, 0x00
	mov ecx, 0x00
	sub bl,cl
	
	mov ebx, 0xFF
	mov ecx, 0x01
	sub bl,cl
	
	mov ebx, 0x01
	mov ecx, 0xFF
	sub bl,cl
	
	
	
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
	
	mov byte [eax],0xBD
	mov dword [eax+1],0
	mov byte [ebx],0xBE
	mov dword [ebx+1],0
	mov byte [ecx],0xBF
	mov dword [ecx+1],0
	
	push ecx
	push ebx
	push eax
	call compare
	add esp,12
	; end of main
returnAddress:
	mov ecx, eax
	
;	push ecx
;	call DebugPrintNumber
;	add esp, 4
	push ecx
	push X_STRING
	call printf
	add esp, 8
	
	
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