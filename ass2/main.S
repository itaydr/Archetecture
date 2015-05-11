section .bss

section	.data
LC0:
	DB	"blaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa", 10, 0	; Format string
LC1:
	DB "", 10, 0
PLUS_CARRY_FLAG:	DB	0
PLUS_CONTINUE_FLAG:	DB	0
I:	DB	0
IS_VALID_NUM: DB 0
LAST_STRUCT: DB 0
FIRST_STRUCT: DB 0

section .text
	align 32
	global main
	extern malloc
	extern free
	extern gets 

main:
	; Read num
	push LC0
	call gets
	add esp, 4

parseLoop:
	; Handle first of 2 chars
	mov byte [IS_VALID_NUM], 0
	mov eax, 0
	add eax, [I]
	add eax ,LC0													;; We have an error here on the second loop. Probably bad address.
	mov bl, [eax]
	cmp bl, 0
	jz parseLoopEnd

;check quit
	cmp bl, 'q'
	jz Quit
	cmp bl, 'Q'
	jz Quit

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
	mov bl, [LC0 + 1]

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

	add byte [I], 1
	jmp parseLoop
parseLoopEnd:



errorBadNumber:
	; We recived a bad number


Quit:
	; Program should quit


