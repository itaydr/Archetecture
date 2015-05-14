freeLinkList:
	;; Function freeLinkList:
	;	args: 	[ebp+8]	 - pointer to num A
	;	return:	eax - 0
	
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
	mov eax, 0
	
	pop ebp
	ret