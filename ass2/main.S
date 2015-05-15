section .bss

section	.data
LC0:
	DB	"$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$", 10, 0	; Format string
LC1:
	DB "", 10, 0
X_STRING:
	DB	"%x", 00
CRASH_STRING:
	DB	0x0d, 0x0a, "Crashing because i dont know to exit windows..." ,00

X_2_STRING:
	DB	"%02x", 00
X_1_STRING:
	DB	"%x", 00
NEWLINE:
	DB 10, 00
PROMPT:
	DB "calc: ", 00

RPN_ZERO:
	DB	00,00,00,00,00
RPN_ONE:
	DB	01,00,00,00,00

PLUS_CARRY_FLAG:	DB	0
PLUS_CONTINUE_FLAG:	DB	0
I:	DD	0, 10, 0
I_2:	DD	0, 10, 0
IS_VALID_NUM: DD 0, 10, 0
LAST_STRUCT: DD 0
BASEP: DD 0
STACKP: DD 0
SZ: DD 20 ; 4 bytes for 5 slots
IS_NOT_EVEN: DD 0
SHOULD_CHECK_LEADING_ZERO: DD 0


section .text
	align 32
	global main
	extern malloc
	extern free
	extern printf
	extern gets 
	

main:
	; Allocate stack and save base pointer to it in BASEP
	mov eax, 0
	mov al, [SZ]
	push eax
	call malloc
	add esp,4
	mov [BASEP], eax

read:
	; Read num

	push PROMPT
	call printf
	add esp, 4

	push LC0
	call gets
	add esp, 4
	mov dword [I], 0
	mov dword [IS_VALID_NUM], 0
	mov dword [IS_NOT_EVEN], 0
	mov byte [SHOULD_CHECK_LEADING_ZERO], 1

	add dword [I_2], 0
checkIfNotEven:
	mov eax, 0
	add al, [I]
	add eax ,LC0										
	mov bl, [eax]
	cmp bl, 0
	jz checkIfNotEven_end

	add dword [I], 1 

	; check leading zeros
	cmp byte [SHOULD_CHECK_LEADING_ZERO], 1
	jnz not_leading_zero_2
	cmp bl, '0'
	jz checkIfNotEven

not_leading_zero_2:
	mov dword [SHOULD_CHECK_LEADING_ZERO], 0 ; we found a number, stop looking for leading zeros.

	add dword [I_2], 1 ; increment the counter of real digits (not zeros)
	jmp checkIfNotEven
checkIfNotEven_end:

	mov dword [I], 0
	mov eax, [I_2]
	mov dword [I_2], 0
	mov dword [SHOULD_CHECK_LEADING_ZERO], 1
	and eax, 1
	cmp eax, 0
	jz parseLoop
	mov byte [IS_NOT_EVEN], 1 ; remember we are not even.

parseLoop:
	; Handle first of 2 chars
	mov byte [IS_VALID_NUM], 0
	mov eax, 0
	add al, [I]
	add eax ,LC0													;; We have an error here on the second loop. Probably bad address.
	mov bl, [eax]
	cmp bl, 0
	jz parseLoopEnd

;check quit
	cmp bl, 'q'
	jz Quit
	cmp bl, 'Q'
	jz Quit

; check leading zeros
	cmp byte [SHOULD_CHECK_LEADING_ZERO], 1
	jnz not_leading_zero
	cmp bl, '0'
	jnz not_leading_zero
	add dword [I], 1 ; advance to the next digit.
	jmp parseLoop

not_leading_zero:
mov dword [SHOULD_CHECK_LEADING_ZERO], 0

; check plus
	cmp bl, '+'
	jnz not_plus
	; pop 1
	mov eax, [BASEP]
	mov ebx, 0
	mov bl, [STACKP]
	add bl, -4
	mov [STACKP], bl
	add al, bl
	mov eax, [eax]
	push eax

	; pop 2
	mov eax, [BASEP]
	mov ebx, 0
	mov bl, [STACKP]
	add bl, -4
	mov [STACKP], bl
	add al, bl
	mov eax, [eax]
	push eax

	call inline_plus
	add esp,4
	pop ebx
	push eax
	push ebx
	call freeLinkList
	add esp,4
	pop eax

	
	; save num in stack
	mov ecx, 0
	mov ebx, [BASEP]
	add ebx, [STACKP]
	add ecx, ebx
	mov ebx, 0
	mov [ecx], eax

	;Increment stack pointer
	add byte [STACKP], 4

	jmp read

not_plus:

; check shift left
	cmp bl, '^'
	jnz not_shift_left
	; pop 1
	mov eax, [BASEP]
	mov ebx, 0
	mov bl, [STACKP]
	add bl, -4
	mov [STACKP], bl
	add al, bl
	mov eax, [eax]
	push eax

	; pop 2
	mov eax, [BASEP]
	mov ebx, 0
	mov bl, [STACKP]
	add bl, -4
	mov [STACKP], bl
	add al, bl
	mov eax, [eax]
	push eax

	call power_2_y
	add esp,4
	pop ebx
	push eax
	push ebx
	call freeLinkList
	add esp,4
	pop eax

	; save num in stack
	mov ecx, 0
	mov ebx, [BASEP]
	add ebx, [STACKP]
	add ecx, ebx
	mov ebx, 0
	mov [ecx], eax

	;Increment stack pointer
	add byte [STACKP], 4

	jmp read
not_shift_left:

; check shift right
	cmp bl, 'v'
	jnz not_shift_right
	; pop 1
	mov eax, [BASEP]
	mov ebx, 0
	mov bl, [STACKP]
	add bl, -4
	mov [STACKP], bl
	add al, bl
	mov eax, [eax]
	push eax

	; pop 2
	mov eax, [BASEP]
	mov ebx, 0
	mov bl, [STACKP]
	add bl, -4
	mov [STACKP], bl
	add al, bl
	mov eax, [eax]
	push eax

	call power_2_minus_y
	add esp,4
	pop ebx
	push eax
	push ebx
	call freeLinkList
	add esp,4
	pop eax

	; save num in stack
	mov ecx, 0
	mov ebx, [BASEP]
	add ebx, [STACKP]
	add ecx, ebx
	mov ebx, 0
	mov [ecx], eax

	;Increment stack pointer
	add byte [STACKP], 4

	jmp read
not_shift_right:

; check pop and print
	cmp bl, 'p'
	jnz not_pop
	; pop 1
	mov eax, [BASEP]
	mov ebx, 0
	mov bl, [STACKP]
	add bl, -4
	mov [STACKP], bl
	add al, bl
	mov eax, [eax]
	push eax
	call DebugPrintNumber
	call freeLinkList
	add esp,4

	push NEWLINE
	call printf
	add esp,4

	jmp read
not_pop:

; check duplicate
	cmp bl, 'd'
	jnz not_dup
	; pop 1
	mov eax, [BASEP]
	mov ebx, 0
	mov bl, [STACKP]
	add bl, -4
	add al, bl
	mov eax, [eax]
	push eax

	call duplicate
	add esp,4

	; save num in stack
	mov ecx, 0
	mov ebx, [BASEP]
	add ebx, [STACKP]
	add ecx, ebx
	mov ebx, 0
	mov [ecx], eax

	;Increment stack pointer
	add byte [STACKP], 4

	jmp read
not_dup:

; check number of ones
	cmp bl, 'n'
	jnz not_noo
	; pop 1
	mov eax, [BASEP]
	mov ebx, 0
	mov bl, [STACKP]
	add bl, -4
	mov [STACKP], bl
	add al, bl
	mov eax, [eax]
	push eax

	call countBits
	pop ebx
	push eax
	push ebx
	call freeLinkList
	add esp,4
	pop eax
	

	; save num in stack
	mov ecx, 0
	mov ebx, [BASEP]
	add ebx, [STACKP]
	add ecx, ebx
	mov ebx, 0
	mov [ecx], eax

	;Increment stack pointer
	add byte [STACKP], 4

	jmp read
not_noo:

;check digit
	cmp bl, '0'     ; handle 0-9
	jl notDigit
    cmp bl, '9'
    jg notDigit
	mov byte [IS_VALID_NUM], 1
    sub bl, '0'     ; convert to numeric value
    shl bl, 4		; multiply by 4. ( 00000010 -> 00100000 )
	mov byte [LC1], bl
	jmp parseSecondByte
notDigit:

;check for upper case:
        cmp bl, 'A'     ; handle A-F
        jl notUpper
        cmp bl, 'F'
        jg notUpper
		mov byte [IS_VALID_NUM], 1
        sub bl, 'A'-10  ; convert to numeric value
        shl bl, 4
		mov byte [LC1], bl
		jmp parseSecondByte
notUpper:

parseSecondByte:

	; restore the shift if we only need one byte from this.
	cmp byte [IS_NOT_EVEN], 1
	jnz even_number
	mov ebx, 0
	mov bl, [LC1]
	shr bl, 4
	mov byte [LC1], bl
	jmp notUpper_2

even_number:

	; Handle second of two chars.
	mov eax, 1
	add al, [I]
	add eax ,LC0						
	mov bl, [eax]

;check digit
	cmp bl, '0'     ; handle 0-9
	jl notDigit_2
    cmp bl, '9'
    jg notDigit_2
	mov byte [IS_VALID_NUM], 1
    sub bl, '0'     ; convert to numeric value
	add bl, [LC1]
	mov byte [LC1], bl
notDigit_2:

;check for upper case:
        cmp bl, 'A'     ; handle A-F
        jl notUpper_2
        cmp bl, 'F'
        jg notUpper_2
		mov byte [IS_VALID_NUM], 1
        sub bl, 'A'-10  ; convert to numeric value
		add bl, [LC1]
		mov byte [LC1], bl
notUpper_2:

	cmp byte [IS_VALID_NUM], 0
	js  errorBadNumber

	push 5
	call malloc
	add esp,4

	mov dword [eax+1],0
	mov byte [eax],0
										
	; Save our byte 
	mov bl, [LC1]
	mov byte [eax], bl
	mov dword [eax + 1], 0 ;
	; If this is not the first loop - we have a previous struct, and we want to connect it to the new one.
	cmp dword [LAST_STRUCT], 0
	jz afterConnectPreviousStruct 
	mov ecx, [LAST_STRUCT]
	mov dword [eax + 1], ecx ; connect the last struct to the new one.
afterConnectPreviousStruct:

	mov dword [LAST_STRUCT], eax ; save this struct for next loop.

	mov ebx ,2 ; 2 because we parse 2 byts at a loop
	cmp byte [IS_NOT_EVEN], 1
	jnz even_number_2
	mov ebx, 1 ; 1 because we only read one byte at the first loop.
	mov byte [IS_NOT_EVEN], 0

even_number_2:
	add dword [I], ebx 
	jmp parseLoop
parseLoopEnd:
	
	; save num in stack
	mov eax, 0
	mov ebx, [BASEP]
	add ebx, [STACKP]
	add eax, ebx
	mov ebx, 0
	mov ebx, [LAST_STRUCT]
	mov [eax], ebx

	;Increment stack pointer
	add byte [STACKP], 4
	mov dword[LAST_STRUCT], 0
	mov byte [IS_NOT_EVEN], 0

	jmp read


errorBadNumber:
	; We recived a bad number


Quit:

clearStackLoop:
cmp byte [STACKP], 0
jz DIE

	; pop 1
	mov eax, [BASEP]
	mov ebx, 0
	mov bl, [STACKP]
	add bl, -4
	mov [STACKP], bl
	add al, bl
	mov eax, [eax]
	push eax

	call freeLinkList
	jmp clearStackLoop

clearStackLoop_end:

DIE:
	; free the stack memory.
	mov eax, [BASEP]
	push eax
	call free
	
	mov ebx, 0
	mov eax, 1
	int 0x80




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;------------------------------------------------------------------------------------------------------
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

;------------------------------------------------------------------------------------------------------


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
	
;------------------------------------------------------------------------------------------------------------------------------------


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


	
;------------------------------------------------------------------------------------------------------------------------------
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
;----------------------------------------------------------------


;------------------------------------------------------------------------------------------------------------------------------------------------------------------
power_2_y:
	;; Function power_2_y:
	;	args: 	[ebp+8]	 	- pointer to num A
	;	args: 	[ebp+12]	 - pointer to num B
	;	return:	eax - pointer to numA after shl B times
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
	call inline_shl
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
	
	
inline_shl:
	;; Function inline_shl:
	;	args: 	[ebp+8]	 - pointer to num A
	;	return:	eax - pointer to numA after shl
	
	push ebp
	mov ebp, esp

	mov eax, [ebp+8]	;arg1
	
	push 0			; initial bit to push from right
	push dword [ebp+8]	; num A
	call inline_shl_rec
	add esp,2*4
	mov eax, [ebp+8]
	
	pop ebp
	ret
	
	
inline_shl_rec:
	;; Function plus:
	;	args: 	[ebp+8]	 - pointer to num A
	;			[ebp+12] - 0 / 1 bit to push from right
	;	return:	none
	
	push ebp
	mov ebp, esp
	
;	sub esp, 16
	mov eax, [ebp+8]	;arg1
	
	cmp eax,0
	jz .done

;;;	mov ebx, [ebp+12]	;arg2 - bit to push from right
	
	shl byte [eax], 1
	jc .hasCarry
	mov ebx, 0
	jmp .afterCarry
.hasCarry:
	mov ebx, 1
.afterCarry:
	; change the old bit from previous chain
	mov edx,[ebp+12]
	or byte [eax], dl
	
	cmp dword [eax+1], 0
	jnz .nextEaxAllocated
	cmp ebx, 0
	jz .done
	
	; allocate eax
	push eax
	push ebx
	
	push 5
	call malloc
	add esp,4
	
	mov dword [eax+1],0
	mov byte  [eax],0
	
	mov edx, eax
	pop ebx
	pop eax
	mov [eax+1], edx
.nextEaxAllocated:
	
	push ebx
	push dword [eax+1]
	call inline_shl_rec
	add esp,8
	
.done:
	pop ebp
	ret
	
;----------------------------------------------------------------------------------------------------------------------------------


;///////----------------------------------------------------------- power_2_minus_y ---------------------------------------
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