;Tasnim Bari Noshin
;400043624

%include "asm_io.inc"

SECTION .data


err1: db "incorrect number of command line arguments (should be 2)",10,0
err2: db "incorrect length of command line argument (less that or equal to 30)",10,0
err3: db "incorrect charecters of command line argument (use '0','1' and '2' only)",10,0
displayLine: db "sorted suffixes:",10,0


SECTION .bss

	y: resd 31
    X: resb 31
    N: resd 1


SECTION .text

        extern printf
        global asm_main

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

sufcmp: 
; ebp+16 Z
; ebp+12 i
; ebp+8 j
	enter 0,0
        pusha

	mov edi, dword[ebp+16]      ;X

	mov ebx, dword [ebp+12]      ;y[j-1]

	mov ecx, dword [ebp+8]      ;y[j]

LoopCmp:
	cmp byte[edi+ebx],  0
	je RetMinus

	cmp byte[edi+ecx], 0
	je RetPlus
	
	mov cl, byte[edi+ecx]
	cmp byte[edi+ebx], cl
	jg RetPlus
	jl RetMinus
	
	inc ebx
	inc ecx
	jmp LoopCmp
RetMinus:
	popa
	mov eax, -1
	jmp Done
RetPlus:
	popa
	mov eax, 1
	jmp Done
Done:
        leave
        ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
asm_main:
        enter 0,0                ;steup routine
        pusha                    ;save all registers

        mov eax, dword [ebp+8]   ;argc
        cmp eax,dword 2          ;argc should be 2
        jne ErrArg                 ;go to ERR1 if not 2 arguments

        ;now we have right number of arguments

        mov ebx, dword [ebp+12]      ;ebx holds the value of  1st arg, pointer to the string
        add ebx, 4
        mov eax, dword[ebx]
        mov esi, 0                   ;increment variable

LoopArg:
                cmp byte [eax], 0      ;compare
                je DoneArg
                cmp esi, 30            ;check if esi is equal to   jg ERR2
                jg ErrLen

        ;now we have correct length

			mov bl,byte[eax]
            try1: cmp bl, '0'            ;compare the character to 0
            jne try2
            je byte_ok
            try2: cmp bl, '1'            ;compare the character to 1
            jne try3
            je byte_ok
            try3: cmp bl, '2'            ;compare the character to 2
            jne ErrChar
            byte_ok:
            inc eax                      ;increment ebx
            inc esi
            jmp LoopArg

          ;now we have right  charecters

DoneArg:
        mov ebx, dword [ebp+12]    ;get the command line arguments
		add ebx, 4
		mov eax, dword[ebx]            ;eax has the input string
		mov [N], esi                   ;sets N as esi(length of the array)
        mov esi, 0                     
		mov ebx, eax

;;;now we have the correct string 
	
LoopX:
    	cmp byte[ebx+esi],byte 0     ;check for the end of string
	    je DoneX
	    mov eax,0                    ;empty ebx
	    mov al, byte[ebx+esi]        ;copy string position into al
	    mov byte[X+esi], al          ;copy value in al into array X in memory
	    push eax
	    mov eax,0
	    mov al, byte[X+esi]
	    call print_char
	    pop eax
	    inc esi
	    jmp LoopX
DoneX:
		call print_nl               ;print newline
		mov eax, 0
		mov esi, 0
		mov ebx,0
	
LoopY:
		cmp esi, dword [N]
		je DoneY
		mov eax, 4
		mul esi
		mov [y+eax], esi
		inc esi
		jmp LoopY
DoneY:
		mov eax, 0
		mov esi, 0

	mov esi, [N]                   ;the length i

LoopOut:	       	  
	 mov edx, dword 1                     ;incrementor j, reset
	 cmp esi,dword 0              ;compare to see if esi is 0, esi is i
	je DoneOut
	 LoopIn:
		cmp edx, esi              ;compare to see if i equals to i
		je DoneIn			
                mov eax, X
		push eax                  ;push the string on the stack

		mov eax, edx
		dec eax
		mov eax, dword[y+eax*4]				
		push eax            ;push y[j-1]

		mov eax, edx
		mov eax, dword[y+eax*4]
		push eax               ;push y[j]				

	call sufcmp

		add esp, 12               
		cmp eax,0                 ;the return value of sufcmp is saved in result, so compare to 0	
		jg Swap
		jmp DoneSwap
	Swap:
		mov ecx, 0         ;ecx is the temp variable
		                   
      	        mov ecx, dword[y+edx*4]			;ecx: y[j]
		mov ebx, edx
		dec ebx
		
       	        mov edi, dword[y+ebx*4]                 ;edi: y[j-1]
		mov [y+edx*4],edi
		mov [y+ebx*4], ecx

	DoneSwap:
		inc edx
		jmp LoopIn
	DoneIn:		
		dec esi
		jmp LoopOut
DoneOut:
	mov esi, 0                ;esi is counter i
	mov eax, displayLine      ; get desplayLine
	call print_string
LoopPrint:
	cmp esi, [N]
	je DonePrint
	mov eax, X                 ;Z
	mov ecx, dword[y+esi*4]    ;y[i]
	add eax, ecx               ;Z[y[i]]
	call print_string		
	call print_nl
	inc esi
	jmp LoopPrint
DonePrint:
	jmp asm_main_end

ErrArg:
                mov eax,err1    ;get err1
                call print_string   ;print err1
                jmp asm_main_end

ErrLen:
                mov eax, err2     ;get err2
                call print_string   ;print err2
                jmp asm_main_end
ErrChar:
                mov eax,err3       ;get err3
                call print_string    ;print err3
                jmp asm_main_end
asm_main_end:
                popa
                leave
                ret

