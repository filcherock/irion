[BITS 16]
[ORG 800h]

jmp start

%include "lib/ic32.inc"
%include "lib/utils.inc"

start:
    pusha
    mov ax, 0x03
    int 0x10
    popa

    mov dl, 0 
    mov dh, 0
    call set_cursor_pos

    mov si, text
    call print_string

text db "Hello, world!", 0