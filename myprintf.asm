global _my_print
section .bss
    buffer resb 8                         ; reserve 1024 bytes (in uninitialized memory section) переполнение
section .rodata                           ; section only for read
align 8

JUMP_TABLE:
dq BIN
dq CHAR
dq DECIMAL
times 'n' - 'e' + 1 dq DEF
dq OCTAL
times 'r' - 'p' + 1 dq DEF
dq STRING
times 'w' - 't' + 1 dq DEF
dq HEXADECIMAL

section .text
_my_print:

;=========================================================CDECL:===============================================================
    push r9                               ;
    push r8                               ; 1) arguments in stack (push func's arguments to stack by the function that calls it)
    push rcx                              ; 2) the stack is cleared by the function that calls it
    push rdx                              ; 3) return value in eax
    push rsi                              ; 4) names functions with __
    push rdi                              ;
;===============================================================================================================================

    push rbp                              ; save rbp
    mov rbp, rsp                          ; rbp - counter for stack

    add rbp, 8
    mov rsi, [rbp]                        ; get rdi

    call _copy_buffer
    call _print_buffer

    pop rbp
    mov rax, 60                           ; 60 - num exit
    syscall                               ; system call exit

_copy_buffer:
    xor rcx, rcx                          ; rcx - counter for buffer
COPY:
    mov al, [rsi]                         ; rsi - conter for main string

    cmp al, 0                             ; check  /0
    je END_COPY

    cmp al, '%'
    je SWITCH_CONSTRUCTION

    call _check_size_buffer
    mov [buffer + rcx], al                ; record to buffer
    inc rcx
    inc rsi

    jmp COPY

END_COPY:
    call _check_size_buffer
    mov [buffer + rcx], al
    ret

SWITCH_CONSTRUCTION:
    inc rsi
    mov al, [rsi]
    cmp al, '%'
    je PERCENT

    add rbp, 8
    mov rdx, [rbp]                        ; get arguments

    sub al, 'b'                           ; numbering symbols (b - 0)
    movzx rax, al
    jmp [JUMP_TABLE + rax * 8]

DECIMAL:
    mov rbx, rcx                          ; save buffer position
    xor rcx, rcx                          ; rcx- length counter
    mov eax, edx                          ; current number in eax (for div)

convert_to_decimal:
    xor rdx, rdx
    mov r8, 10                            ; dimension
    div r8                                ; result in edx

    add dl, '0'                           ; change to symbol
    push rdx                              ; on stack (to reverse)
    inc rcx
    test eax, eax                         ; check if edx == 0
    jnz convert_to_decimal                ; continue if there are more digits

write_decimal:
    pop rdx                               ; get number from stack

    push rcx
    call _check_size_buffer
    cmp rcx, 0
    jne NOT_CHANGE_RCX10                  ; func!!!
    mov rbx, 0
NOT_CHANGE_RCX10:
    pop rcx

    mov [buffer + rbx], dl                ; record to buffer
    inc rbx
    loop write_decimal

    mov rcx, rbx                          ; update buffer position
    inc rsi
    jmp COPY                              ; continue

BIN:
    mov [buffer + rcx], rdx               ; record to buffer
    inc rcx
    inc rsi
    jmp COPY

HEXADECIMAL:
    mov rbx, rcx                          ; save buffer position
    xor rcx, rcx                          ; rcx- length counter

convert_to_hexadecimal:
    mov eax, edx                          ; copy number
    and eax, 1111b                        ; get 4 bits with help mask
    cmp al, 9
    jbe number
    add al, 7
number:
    add al, '0'

    push rax                              ; on stack (to reverse)
    shr edx, 4                            ; shift right by 4 bits (next octal digit)
    inc rcx
    test edx, edx                         ; check if edx == 0
    jnz convert_to_hexadecimal            ; continue if there are more digits

write_hexadecimal:
    pop rax                               ; get number from stack

    push rcx
    call _check_size_buffer
    cmp rcx, 0
    jne NOT_CHANGE_RCX16
    mov rbx, 0
NOT_CHANGE_RCX16:
    pop rcx

    mov [buffer + rbx], al                ; record to buffer
    inc rbx
    loop write_hexadecimal

    mov rcx, rbx                          ; update buffer position
    inc rsi
    jmp COPY                              ; continue

OCTAL:
    mov rbx, rcx                          ; save buffer position
    xor rcx, rcx                          ; rcx- length counter

convert_to_octal:
    mov eax, edx                          ; copy number
    and eax, 0111b                        ; get 3 bits with help mask
    add al, '0'                           ; convert to ASCII

    push rax                              ; on stack (to reverse)
    shr edx, 3                            ; shift right by 3 bits (next octal digit)
    inc rcx
    test edx, edx                         ; check if edx == 0
    jnz convert_to_octal                  ; continue if there are more digits

write_octal:
    pop rax                               ; get number from stack

    push rcx
    call _check_size_buffer
    cmp rcx, 0
    jne NOT_CHANGE_RCX08
    mov rbx, 0
NOT_CHANGE_RCX08:
    pop rcx

    mov [buffer + rbx], al                ; record to buffer
    inc rbx
    loop write_octal

    mov rcx, rbx                          ; update buffer position
    inc rsi
    jmp COPY                              ; continue

CHAR:
    call _check_size_buffer
    mov [buffer + rcx], rdx               ; record to buffer
    inc rcx
    inc rsi
    jmp COPY

STRING:
COPY_STRING:
    mov al, [rdx]

    cmp al, 0                             ; check /0
    je END_COPY_STRING

    call _check_size_buffer
    mov [buffer + rcx], al                ; record to buffer
    inc rcx
    inc rdx

    jmp COPY_STRING

END_COPY_STRING:
    inc rsi
    jmp COPY

PERCENT:
    call _check_size_buffer
    mov byte [buffer + rcx], '%'          ; record to buffer
    inc rcx
    inc rsi
    jmp COPY

DEF:
    jmp COPY

_print_buffer:
    mov rax, 1                            ; 1 - number write
    mov rdi, 1                            ; 1 - number stdout
    lea rsi, [buffer]
    mov rdx, rcx                          ; size (byte)
    syscall                               ; system call write
    ret

_check_size_buffer:
    cmp rcx, 512
    jbe GOOD_SIZE
    call _print_buffer
    xor rcx, rcx
GOOD_SIZE:
    ret
