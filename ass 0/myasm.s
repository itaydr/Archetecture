section .data                    	; data section, read-write
        an:    DD 0              	; this is a temporary var

section .text                    	; our code is always in the .text section
        global strToLeet          	; makes the function appear in global scope
        extern printf            	; tell linker that printf is defined elsewhere 				; (not used in the program)

strToLeet:                        	; functions are defined as labels
        push    ebp              	; save Base Pointer (bp) original value
        mov     ebp, esp         	; use base pointer to access stack contents
        pushad                   	; push all variables onto stack
        mov ecx, dword [ebp+8]	; get function argument

;;;;;;;;;;;;;;;; FUNCTION EFFECTIVE CODE STARTS HERE ;;;;;;;;;;;;;;;; 

	mov	dword [an], 0		; initialize answer
label_here:

   ; Your code goes somewhere around here...
	cmp byte [ecx], 'A'
	jz FIX_A
	
	cmp byte [ecx], 'B'
	jz FIX_B
	
	cmp byte [ecx], 'C'
	jz FIX_C  

	cmp byte [ecx], 'E'
	jz FIX_E 
	
	cmp byte [ecx], 'G'
	jz FIX_G 
	
	cmp byte [ecx], 'H'
	jz FIX_H  
	
	cmp byte [ecx], 'I'
	jz FIX_I 
	
	cmp byte [ecx], 'L'
	jz FIX_L 
	
	cmp byte [ecx], 'O'
	jz FIX_O 
	
	cmp byte [ecx], 'S'
	jz FIX_S 
	
	cmp byte [ecx], 'T'
	jz FIX_T 
	
	cmp byte [ecx], 'Z'
	jz FIX_Z 
   
	cmp byte [ecx], 'A'
	jl CONTINUE
	
	cmp byte [ecx], 'Z'
	jg CONTINUE
	
	add byte [ecx], 32
	
	jmp CONTINUE
	
INC_ANS:
	inc byte [an]
CONTINUE:
	inc	ecx      		; increment pointer
	cmp	byte [ecx], 0    		; check if byte pointed to is zero
	jz	EXIT       		; keep looping until it is null terminated
	jmp label_here
EXIT:

;;;;;;;;;;;;;;;; FUNCTION EFFECTIVE CODE ENDS HERE ;;;;;;;;;;;;;;;; 
         popad                    ; restore all previously used registers
         mov     eax,[an]         ; return an (returned values are in eax)
         mov     esp, ebp
         pop     ebp
         ret

		 
FIX_A :
	mov byte [ecx], '4'
	jmp INC_ANS

FIX_B:
	mov byte [ecx], '8'
	 jmp INC_ANS

FIX_C :
	mov byte [ecx], '('
	 jmp INC_ANS
		 
FIX_E :
	mov byte [ecx], '3'
	 jmp INC_ANS

FIX_G :
	mov byte [ecx], '6'
	 jmp INC_ANS

FIX_H :
	mov byte [ecx], '#'
	 jmp INC_ANS
		 
FIX_I :
	mov byte [ecx], '!'
	 jmp INC_ANS

FIX_L :
	mov byte [ecx], '1'
	 jmp INC_ANS

FIX_O :
	mov byte [ecx], '0'
	 jmp INC_ANS
	
FIX_S :
	mov byte [ecx], '5'
	 jmp INC_ANS

FIX_T :
	mov byte [ecx], '7'
	 jmp INC_ANS

FIX_Z :
	mov byte [ecx], '2'
	 jmp INC_ANS