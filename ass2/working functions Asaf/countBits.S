;;--------------------------------------------------------------------------------------
countBits:
	;; Function countBits:
	;	args: 	[ebp+8]	 	- pointer to num A to count the '1' bits in it
	;	return:	eax - pointer to num B that contains the number of '1' bits in num A
	push ebp
	mov ebp,esp
	
	xor ecx,ecx		; set the counter to 0
	
	push dword [ebp+8]
	call countBitsHelper
	add esp, 4
	
	push ecx
	call createRPNnum
	add esp,4
	
	pop ebp
	ret
	
	
countBitsHelper:
	;; Function countBitsHelper:
	;	args: 	[ebp+8]	 - pointer to chain in num A
	;	return:	none - increase ecx for every '1' in current chain
	
	push ebp
	mov ebp, esp

	mov eax, [ebp+8]	;arg1
	
	; sanity check if we are at the end
	cmp eax, 0
	jz .done
	
	; initialize
	xor edx,edx
	xor ebx,ebx
	mov dl, [eax]
	
.loop:
	mov bl,dl
	and bl,1
	add ecx,ebx
	shr dl, 1
	cmp dl,0
	jnz .loop
	
.done_calculate:
	mov eax, [eax+1]
	
	push eax
	call countBitsHelper
	add esp, 4
.done:
	pop ebp
	ret

createRPNnum:
	;; Function createRPNnum:
	;	args: 	[ebp+8]	 - register with num of '1' to create RPN number
	;	return:	eax - pointer to num of '1' to create RPN number
	
	push ebp
	mov ebp, esp

	mov ebx, [ebp+8]	;arg1 - number

	push 5
	call malloc
	add esp,4
	mov byte  [eax],0
	mov dword [eax+1],0

	mov ecx, eax	; ecx holds start of chain
	
	cmp ebx, 0
	jz .done
	
.createNode:
	mov edx, ebx
	mov [eax], bl
	
	shr ebx, 8
	
	cmp ebx, 0
	jz .done
	
	push ecx
	push ebx
	push eax
	
	push 5
	call malloc
	add esp,4
	mov byte  [eax],0
	mov dword [eax+1],0

	pop ebx
	mov dword [ebx+1], eax
	
	pop ebx
	pop ecx
	
	jmp .createNode
.done:
	mov eax, ecx
	pop ebp
	ret

;------------------------------------------------------------------------------------------------