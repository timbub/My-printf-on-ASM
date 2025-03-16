global _my_print

section .bss
    buffer resb 512     ; reserve 1024 bytes (in uninitialized memory section)

section .text
_my_print:
    push rdi
    push rsi
    push rdx            ; push to stack for cdecl
    push rcx
    push r8
    push r9

    push rbp            ; save rbp
    mov rbp, rsp        ; get top of stack
    mov rsi, [rbp + 8*6]                ; get rdi

    push rcx
    call _copy_buffer
    call _print_buffer
    pop rcx

    mov rax, 60         ; 60 - num exit
    syscall             ; system call exit

_copy_buffer:
    xor rcx, rcx
    lea r8, [rel buffer]
copy:
    mov al, [rsi]
    test al, al                         ; check if rsi == /0
    jz end_copy

    mov [r8 + rcx], al
    inc rcx
    inc rsi

    jmp copy

    end_copy:
    mov [r8 + rcx], al
    ret


_print_buffer:
    mov rax, 1          ; 1 - number write
    mov rdi, 1          ; 1 - number stdout
    lea rsi, [rel buffer]
    mov rdx, rcx         ; size (byte)
    syscall             ; system call write
    ret
