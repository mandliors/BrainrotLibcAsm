section .data
    sigma               db "s%cgma %s %d420", 10, 0
    rizz                db 'i'
    ohio                db "mogger", 0

section .bss
    stdHandle   resb 4

section .text
    extern  _GetStdHandle@4
    extern  _WriteFile@20
    extern  _ExitProcess@4

    global _main

_main:
    mov     ebp, esp
    sub     esp, 4

    push    -11
    call    _GetStdHandle@4
    mov     dword [stdHandle], eax
    
    movzx   eax, byte [rizz]

    push    69
    push    ohio
    push    eax
    push    sigma
    call    yapf
    add     esp, 8

    push    0
    call    _ExitProcess@4


; void yapf(char* format, ...)
yapf:
    push    ebp
    mov     ebp, esp

    push    ebx                     ; stores for the index of the current char
    push    esi                     ; stores for the string (char*)
    push    edi                     ; stores for parameter index

    mov     esi, dword [ebp+8]      ; pointer to the first char
    xor     ebx, ebx                ; index of the current char
    xor     edi, edi                ; set the variadic arg index to 0

_yapf_loopMainStart:
    lea     eax, [esi+ebx]          ; current char pointer
    movzx   edx, byte [eax]         ; current char

    ; check for null-terminator
    cmp     edx, 0
    je      _yapf_return

    ; check for %
    cmp     edx, 37
    jne     _yapf_printChar

    ; return if the string ends with %
    inc     ebx
    lea     eax, [esi+ebx]          ; pointer to the char after the %
    movzx   edx, byte [eax]         ; the char after the %
    cmp     edx, 0
    je      _yapf_return

    ; check char after %
    cmp     edx, 99                 ; %c
    jne     _yapf_notC

    push    eax
    
    lea     eax, [ebp+12]           ; first variadic arg
    movzx   eax, byte [eax+4*edi]   ; current variadic arg as char
    
    push    eax
    call    yapc
    add     esp, 4

    pop     eax

    inc     edi
    jmp     _yapf_noPrintChar

_yapf_notC:
    cmp     edx, 115                ; %s
    jne     _yapf_notS
    
    push    eax
    
    lea     eax, [ebp+12]            ; first variadic arg
    mov     eax, dword [eax+4*edi]   ; current variadic arg as char*
    
    push    eax
    call    yaps
    add     esp, 4

    pop     eax

    inc     edi
    jmp     _yapf_noPrintChar

_yapf_notS:
    cmp     edx, 100                ; %d
    jne     _yapf_notD
    
    push    eax

    lea     eax, [ebp+12]            ; first variadic arg
    mov     eax, dword [eax+4*edi]   ; current variadic arg as int

    push    eax
    call    yapd
    add     esp, 4

    pop     eax

    inc     edi
    jmp     _yapf_noPrintChar

_yapf_notD:
    cmp     edx, 37
    je     _yapf_printChar

    ; if not a valid format char after %
    jmp     _yapf_return

_yapf_printChar:
    movzx   ecx, byte [eax]
    push    ecx
    call    yapc
    add     esp, 4
    
_yapf_noPrintChar:
    ; step to the next char
    inc     ebx                     ; step the index to the next char
    jmp     _yapf_loopMainStart

_yapf_return:
    pop     edi
    pop     esi
    pop     ebx

    mov     esp, ebp
    pop     ebp
    ret


; void yapc(char charToPrint)
yapc:
    push    ebp
    mov     ebp, esp

    sub     esp, 4

    push    0                       ; lpOverlapped
    lea     ecx, dword [ebp-4]
    push    ecx                     ; lpNumberOfBytesWritten
    push    1                       ; nNumberOfBytesToWrite
    lea     eax, [ebp+8]
    push    eax                     ; lpBuffer
    push    dword [stdHandle]       ; hFile
    call    _WriteFile@20

    add     esp, 4

    mov     esp, ebp
    pop     ebp
    ret

; void yaps(char* string)
yaps:
    push    ebp
    mov     ebp, esp

    push    dword [ebp+8]
    call    measure_rizz            ; calculate string length
    add     esp, 4

    sub     esp, 4

    push    0                       ; lpOverlapped
    lea     ecx, dword [ebp-4]
    push    ecx                     ; lpNumberOfBytesWritten
    push    eax                     ; nNumberOfBytesToWrite
    push    dword [ebp+8]           ; lpBuffer
    push    dword [stdHandle]       ; hFile
    call    _WriteFile@20

    add     esp, 4

    mov     esp, ebp
    pop     ebp
    ret

; void yapd(int numberToPrint)
yapd:
    push    ebp
    mov     ebp, esp

    mov     eax, dword [ebp+8]      ; the given number
    push    -1                      ; marks the end of the number
    
    ; push the digits onto the stack
_yapd_pushLoopStart:
    xor     edx, edx                ; clear EDX (important for division)
    mov     cx, 10                  ; divisor in CX
    div     cx                      ; quotient in AX, remainder in DX

    push    edx                     ; push the first digit
    
    cmp     eax, 0                  ; if there are remaining digits
    jg      _yapd_pushLoopStart

    ; pop the digits off of the stack and print them
_yapd_popLoopStart:
    pop     eax
    
    cmp     eax, -1
    je      _yapd_return

    add     eax, 48                 ; convert digit to char

    push    eax
    call    yapc
    add     esp, 4

    jmp     _yapd_popLoopStart

_yapd_return:
    mov     esp, ebp
    pop     ebp
    ret


; int measure_rizz(char* string)
measure_rizz:
    push    ebp
    mov     ebp, esp

    mov     eax, dword [ebp+8]

_measure_rizz_loopStart:
    movzx   ecx, byte [eax]
    cmp     ecx, 0
    je      _measure_rizz_return

    inc     eax
    jmp     _measure_rizz_loopStart

_measure_rizz_return:
    mov     ecx, dword [ebp+8]
    sub     eax, ecx

    mov     esp, ebp
    pop     ebp
    ret

; int fanum_tax(char* numberStr)
fanum_tax:
    push    ebp
    mov     ebp, esp

    xor     ecx, ecx                ; resulting integer
    xor     eax, eax                ; char index

_fanum_tax_loopStart:
    imul    ecx, 10

    mov     edx, dword [ebp+8]      ; get char*
    movzx   edx, byte [edx+eax]     ; get char
    
    cmp     edx, 0
    je      _fanum_tax_return

    sub     edx, 48                 ; get int from char
    add     ecx, edx

    inc     eax
    jmp     _fanum_tax_loopStart

_fanum_tax_return:
    mov     eax, ecx

    mov     esp, ebp
    pop     ebp
    ret


; bool chat_is_this_real(char digitOrNotDigit)
chat_is_this_real:
    push    ebp
    mov     ebp, esp

    xor     eax, eax

    movzx   eax, byte [ebp+8]
    sub     eax, 48
    
    cmp     eax, 0
    jl      _chat_is_this_real_return       ; smaller than 0

    cmp     eax, 9
    jg      _chat_is_this_real_return       ; less than or equals 9

    mov     eax, 1

_chat_is_this_real_return:
    mov     esp, ebp
    pop     ebp
    ret