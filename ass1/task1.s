section .data                    	; data section, read-write
        counter:    DD 0              	; counts till 4 to create each hex from 4 chars
	position:   DD 0              	; the position of the char to read
	fullWordCounter:   DD 0        ; counts till 32
	tempChar:	DD 0		; Var for using reading the '1' and '0'
	temp1:	DD 0			;
	outputChar: DD 0		;
section	.rodata
LC0:
	DB	"The result is:  %s", 10, 0	; Format string
HERE_STR:
	DB	"HERE", 10, 0	; Format string
CHAR_PRINT_FORMAT:
	DB	"Char:  %c", 10, 0	; Format string
section .bss

LC1:
	RESB	32


section .text
	align 16
	global my_func
	extern printf
my_func:
	push	ebp
	mov	ebp, esp	; Entry code - set up ebp and esp
	pusha			; Save registers

	mov edx, dword [ebp+8]	; Get argument (pointer to string)
	
	; Here starts the code I added.
	mov byte [fullWordCounter], 0 ; counter to 32 - to end program
	mov byte [counter], 0 ; counter to 4 - used for shifting
	
	
LOOP:	
	cmp byte [fullWordCounter], 32
	jz EXIT
	;call PRINT_HERE
	
	;call PRINT_HERE
	mov al, [edx]
	mov byte[tempChar], al
	
	push tempChar
	call PRINT_CHAR
	
	cmp byte [tempChar], 0 ; Exit if null
	jz EXIT
	
	; It it's 0 we can skip
	cmp byte [tempChar], '1'
	jnz CONTINUE_CHAR_ADD
	
	; Shift
	mov AL, 1 
	mov CL, byte[counter]
	shl AL, CL 
	
	; ADD
	add byte[outputChar], AL
	
CONTINUE_CHAR_ADD:
	; add hex word if we read 4 chars
	cmp ebx, 3
	jnz NEW_WORD_CONTINUE
	
	;TODO
	; Convert output char from the hex number to the hex letter representation
	
	; Save word
	mov AL, byte[outputChar]
	mov BL,byte[LC1]
	add BL, byte[position]
	mov byte [BL], AL
	; increment next position to save
	inc byte[position]
	; reset the temp vars
	mov byte [counter], 0 
	mov byte[outputChar], 0
	
NEW_WORD_CONTINUE:
	
	inc edx
	inc byte[fullWordCounter]
	inc byte[counter]
	jmp LOOP
EXIT:
	;mov byte[LC1+16], 0
	;mov byte[LC1+8], 'b'
	;mov byte[LC1], 'a'
	push	LC1		; Call printf with 2 arguments: pointer to str
	push	LC0		; and pointer to format string.
	call	printf
	add 	esp, 8		; Clean up stack after call

	popa			; Restore registers
	mov	esp, ebp	; Function exit code
	pop	ebp
	ret
	
; DEBUG
PRINT_HERE:
    push HERE_STR
    call printf
    add  esp, 4
    ret
    
PRINT_CHAR:
    push CHAR_PRINT_FORMAT
    call printf
    add  esp, 8
    ret

