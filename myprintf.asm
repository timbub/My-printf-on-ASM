global _my_print

section .bss
    buffer resb 512                     ; reserve 1024 bytes (in uninitialized memory section)

section .rodata                        ; section only for read
align 8

JUMP_TABLE:
dq BIN                                 ; JUMP_TABLE[0]==
dq CHAR                                ; JUMP_TABLE[1]==
dq DECIMAL                             ; JUMP_TABLE[2]==
dq DEF                                 ; JUMP_TABLE[3]
dq DEF                                 ; JUMP_TABLE[4]
dq DEF                                 ; JUMP_TABLE[5]
dq DEF                                 ; JUMP_TABLE[6]
dq DEF                                 ; JUMP_TABLE[7]
dq DEF                                 ; JUMP_TABLE[8]
dq DEF                                 ; JUMP_TABLE[9]
dq DEF                                 ; JUMP_TABLE[10]
dq DEF                                 ; JUMP_TABLE[11]
dq DEF                                 ; JUMP_TABLE[12]
dq OCTAL                               ; JUMP_TABLE[13]==
dq DEF                                 ; JUMP_TABLE[14]
dq DEF                                 ; JUMP_TABLE[15]
dq DEF                                 ; JUMP_TABLE[16]
dq STRING                              ; JUMP_TABLE[17]==
dq DEF                                 ; JUMP_TABLE[18]
dq DEF                                 ; JUMP_TABLE[19]
dq DEF                                 ; JUMP_TABLE[20]
dq DEF                                 ; JUMP_TABLE[21]
dq HEXADECIMAL                         ; JUMP_TABLE[22]==

section .text
_my_print:

    push r9
    push r8
    push rcx                            ; push func's arguments to stack (cdecl)
    push rdx
    push rsi
    push rdi

    push rbp                            ; save rbp
    mov rbp, rsp                        ; rbp - counter for stack

    add rbp, 8
    mov rsi, [rbp]                      ; get rdi

    push rcx
    call _copy_buffer
    call _print_buffer
    pop rcx

    pop rbp
    mov rax, 60                         ; 60 - num exit
    syscall                             ; system call exit

_copy_buffer:
    xor rcx, rcx                        ; rcx - counter for buffer

COPY:
    mov al, [rsi]                       ; rsi - conter for main string

    cmp al, 0                           ; check  /0
    je END_COPY

    cmp al, '%'
    je  SWITCH_CONSTRUCTION

    mov [buffer + rcx], al                  ; record to buffer
    inc rcx
    inc rsi

    jmp COPY

    END_COPY:
    mov [buffer + rcx], al
    ret

SWITCH_CONSTRUCTION:
    inc rsi
    mov al, [rsi]
    cmp al, '%'
    je PERCENT

    add rbp, 8
    mov rdx, [rbp]                               ; get arguments

    sub al, 'b'                                  ; numbering symbols (b - 0)
    movzx rax, al
    jmp [JUMP_TABLE + rax*8]

DECIMAL:
    add rdx, 48
    mov [buffer + rcx],  rdx                     ; record to buffer
    inc rcx
    inc rsi
    jmp COPY
BIN:
    mov [buffer + rcx],  rdx                     ; record to buffer
    inc rcx
    inc rsi
    jmp COPY
HEXADECIMAL:
    mov [buffer + rcx],  rdx                     ; record to buffer
    inc rcx
    inc rsi
    jmp COPY
OCTAL:
    mov [buffer + rcx],  rdx                      ; record to buffer
    inc rcx
    inc rsi
    jmp COPY
CHAR:
    mov [buffer + rcx],  rdx                      ; record to buffer
    inc rcx
    inc rsi
    jmp COPY
STRING:
    COPY_STRING:
    mov al, [rdx]

    cmp al, 0                           ; check /0
    je END_COPY_STRING

    mov [buffer + rcx], al                  ; record to buffer
    inc rcx
    inc rdx

    jmp COPY_STRING

    END_COPY_STRING:
    inc rsi
    jmp COPY
PERCENT:
    mov byte [buffer + rcx],  '%'                 ; record to buffer
    inc rcx
    inc rsi
    jmp COPY
DEF:
    ;mov byte [buffer + rcx],  '$'                 ; record to buffer
    ;inc rcx
    ;inc rsi
    jmp COPY


_print_buffer:
    mov rax, 1                          ; 1 - number write
    mov rdi, 1                          ; 1 - number stdout
    lea rsi, [buffer]               ;
    mov rdx, rcx                        ; size (byte)
    syscall                             ; system call write
    ret
