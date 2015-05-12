section .bss

section	.data
LC0:
	DB	"$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$", 100, 0	; Format string
LC1:
	DB "", 10, 0
X_STRING:
	DB	"%x", 00
CRASH_STRING:
	DB	0x0d, 0x0a, "Crashing because i dont know to exit windows..." ,00

PLUS_CARRY_FLAG:	DB	0
PLUS_CONTINUE_FLAG:	DB	0
I:	DB	0, 10, 0
IS_VALID_NUM: DB 0, 10, 0
LAST_STRUCT: DB 0
FIRST_STRUCT: DB 0
BASEP: DB 0
STACKP: DB 0
SZ: DB 20 ; 4 bytes for 5 slots

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
	mov eax, [SZ]
	push eax
	call malloc
	add esp,4
	mov [BASEP], eax

read:
	; Read num
	push LC0
	call gets
	add esp, 4
	mov dword [I], 0
	mov dword [IS_VALID_NUM], 0

parseLoop:
	; Handle first of 2 chars
	mov byte [IS_VALID_NUM], 0
	mov eax, 0
	add al, [I]
	add eax ,LC0													;; We have an error here on the second loop. Probably bad address.
	mov bl, [eax]a
	cmp bl, 0
	jz parseLoopEnd

;check quit
	cmp bl, 'q'
	jz Quit
	cmp bl, 'Q'
	jz Quit

; check plus
	cmp bl, '+'
	jnz not_plus
	; pop 1
	mov eax, 0
	mov al, [STACKP]
	dec al
	mov [STACKP], al
	add eax, BASEP
	push eax

	; pop 2
	mov eax, 0
	mov al, [STACKP]
	dec al
	mov [STACKP], al
	add eax, BASEP
	push eax

	call plus
	jmp read
not_plus:

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
	; Handle second of two chars.
	mov eax, 1
	add al, [I]
	add eax ,LC0													;; We have an error here on the second loop. Probably bad address.
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
	
	; Save a pointer for the first struct.
	cmp dword [FIRST_STRUCT], 0
	jnz dontSaveFirst
	mov dword [FIRST_STRUCT], eax
dontSaveFirst:

	; Save our byte 
	mov bl, [LC1]
	mov byte [eax], bl

	; If this is not the first loop - we have a previous struct, and we want to connect it to the new one.
	cmp dword [LAST_STRUCT], 0
	jz afterConnectPreviousStruct 
	mov dword [LAST_STRUCT + 1], eax ; connect the last struct to the new one.
afterConnectPreviousStruct:

	mov dword [LAST_STRUCT], eax ; save this struct for next loop.

	add dword [I], 2 ; 2 because we parse 2 byts at a loop
	jmp parseLoop
parseLoopEnd:
	
	; save num in stack
	mov eax, 0
	mov al, [STACKP]
	add eax, BASEP
	mov ebx, 0
	mov ebx, [FIRST_STRUCT]
	mov [eax], ebx

	;Increment stack pointer
	mov eax, 0
	mov al, [STACKP]
	add al, 4
	mov [STACKP], eax
	mov dword[FIRST_STRUCT], 0

	jmp read


errorBadNumber:
	; We recived a bad number


Quit:
	; Program should quit





;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;; PLUS;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



plus_main:
	;start of main
	pushad
	push esp
	mov ebp, esp
	
	mov eax, LC0
	mov eax, 0x12345678
	
	sub esp, 8	; 3 variables
	
;	push 5
;	call malloc
;	add esp,4
;	mov [ebp-12], eax
	
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
;	mov ecx, [ebp-12]
	
	mov byte [eax],0xFF
	mov dword [eax+1],0
	mov byte [ebx],0xFF
	mov dword [ebx+1],0
	
;	push ecx
	push ebx
	push eax
	call plus
	
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

	
plus:
	;; Function plus:
	;	args: 	[ebp+8]	 - pointer to num A
	;			[ebp+12] - pointer to num B
	;	return:	eax - pointer to new allocated num or 0 if no such num
		
		; TODO continue
		
	push ebp
	mov ebp, esp
	
	sub esp, 16
	
	mov eax, [ebp+8]	;arg1
	mov ebx, [ebp+12]	;arg2
	
	
	; initialization
	mov ecx, 0
	mov byte [PLUS_CARRY_FLAG], 0
		
.plusLoop:	
	;sanity check of to allocate ecx
	cmp eax,0
	jnz .sanityPass
	cmp ebx,0
	jnz .sanityPass
	cmp byte [PLUS_CARRY_FLAG],0
	jnz .sanityPass
	
	jmp .done
	.sanityPass:
	
	; allocate ecx
	; save registers
	mov [ebp-4],   eax
	mov [ebp-8],   ebx
	mov [ebp-12],  ecx
	
	push 5
	call malloc
	add esp, 4
	
	mov ecx, [ebp-12] 	;load ecx before malloc
	
	cmp ecx, 0 ; this is the initial loop
	jz .ecxInitialChain
	mov [ecx+1],eax		;attach it to the new struct
	mov ecx, [ecx+1]	;mov to it
	jmp .ecxReady
.ecxInitialChain:
	mov ecx, eax
	mov [ebp-16],  ecx ; this is the start of the chain!
.ecxReady:

	mov eax, [ebp-4] ;load eax before malloc
	mov ebx, [ebp-8] ;load ebx before malloc
	
	; ready - do the calculation!
	
	xor edx,edx		;reset edx
	mov byte dl,[PLUS_CARRY_FLAG]	; add carry (if any)
	
	; reset carry flag and continuation flag
	mov byte [PLUS_CARRY_FLAG],0
	mov byte [PLUS_CONTINUE_FLAG],0
	
	; add eax number if any
	cmp eax,0
	jz .afterEax
	mov byte [PLUS_CONTINUE_FLAG],1
	add byte dl,[eax]
	mov eax, [eax+1]
	JNC .noCarryFirst
	mov byte [PLUS_CARRY_FLAG],1
.afterEax:
.noCarryFirst:

	; add ebx number if any
	cmp ebx,0
	jz .afterEbx
	mov byte [PLUS_CONTINUE_FLAG],1
	add byte dl, [ebx]
	mov ebx, [ebx+1]
	JNC .noCarrySecond
	mov byte [PLUS_CARRY_FLAG],1
.afterEbx:
.noCarrySecond:
	
	; ecx is allocated, set the value
	mov byte [ecx],dl
	cmp byte [PLUS_CONTINUE_FLAG],0
	jz .done
	
	jmp .plusLoop
	
.done:
	cmp ecx,0
	jz .ecxIsNothing
	mov dword [ecx+1],0
.ecxIsNothing:

;	; free 2 last numbers - load original pointer
;	mov eax,  [ebp+8]	;arg1
;	push eax
;	call freeLinkList
;	add esp, 4
;	
;	mov ebx,  [ebp+12]	;arg2
;	push ebx
;	call freeLinkList
;	add esp, 4
	
	mov eax, [ebp-16] ; load to eax the start of the chain!
	add esp,16 ;clear local variables
	
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

