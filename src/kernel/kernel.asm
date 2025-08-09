[BITS 16]
[ORG 500h]
start:
    cli
    call set_video_mode
    call print_interface
    call print_newline
    call shell
    jmp $

set_video_mode:
    pusha
    mov ax, 0x12
    int 0x10
    popa
    ret

move_cursor_to_top:
    mov ah, 0x02
    mov bh, 0x00
    mov dx, 0x0000
    int 0x10
    ret

; ============================= PRINTS =============================

print_string:
    mov ah, 0x0E
    mov bl, 0x0F
.print_char:
    lodsb
    cmp al, 0
    je .done
    cmp al, 0x0A          ; Check for newline (LF)
    je .handle_newline
    int 0x10              ; Print character
    jmp .print_char
.handle_newline:
    mov al, 0x0D          ; Output carriage return (CR)
    int 0x10
    mov al, 0x0A          ; Output line feed (LF)
    int 0x10
    jmp .print_char
.done:
    ret

print_string_green:
    mov ah, 0x0E
    mov bl, 0x0A
.print_char:
    lodsb
    cmp al, 0
    je .done
    int 0x10
    jmp .print_char
.done:
    ret

print_newline:
    mov ah, 0x0E
    mov al, 0x0D
    int 0x10
    mov al, 0x0A
    int 0x10
    ret

print_help:
    mov si, menu
    call print_string_green
    call print_newline
    ret

print_info:
    mov si, info
    call print_string_green
    call print_newline
    ret

print_interface:
    mov si, header
    call print_string
    mov si, startPrint
    call print_string
    ret

shell:
    mov si, inputAdd
    call print_string
    call read_command
    call print_newline
    call execute_command
    jmp shell

; ============================= INPUT =============================

read_command:
    mov di, command_buffer
    xor cx, cx
.read_loop:
    mov ah, 0x00
    int 0x16
    cmp al, 0x0D
    je .done_read
    cmp al, 0x08
    je .handle_backspace
    cmp cx, 255
    jge .done_read
    stosb
    mov ah, 0x0E
    mov bl, 0x1F
    int 0x10
    inc cx
    jmp .read_loop

.handle_backspace:
    cmp di, command_buffer
    je .read_loop
    dec di
    dec cx
    mov ah, 0x0E
    mov al, 0x08
    int 0x10
    mov al, ' '
    int 0x10
    mov al, 0x08
    int 0x10
    jmp .read_loop

.done_read:
    mov byte [di], 0
    ret

execute_command:
    mov si, command_buffer
    ; Проверка команды "help"
    mov di, help_str
    call compare_strings
    je do_help

    mov si, command_buffer
    ; Проверка команды "help"
    mov di, info_str
    call compare_strings
    je do_info

    mov si, command_buffer
    ; Проверка команды "help"
    mov di, cls_str
    call compare_strings
    je do_cls

    mov si, command_buffer
    ; Проверка команды "help"
    mov di, shut_str
    call compare_strings
    je do_shutdown

    mov si, command_buffer
    ; Проверка команды "help"
    mov di, reboot_str
    call compare_strings
    je do_reboot

    mov si, command_buffer
    ; Проверка команды "help"
    mov di, calc_str
    call compare_strings
    je start_calc


compare_strings:
    xor cx, cx
.next_char:
    lodsb                ; Загружаем следующий символ из команды пользователя
    cmp al, [di]        ; Сравниваем с символом из команды
    jne .not_equal       ; Если не равны, переходим к метке .not_equal
    cmp al, 0           ; Проверяем конец строки
    je .equal           ; Если конец строки, команды равны
    inc di              ; Переходим к следующему символу проверяемой команды
    jmp .next_char      ; Повторяем сравнение
.not_equal:
    ret                 ; Возвращаемся, если команды не равны
.equal:
    ret                 ; Возвращаемся, если команды равны

help_str db 'help', 0
info_str db 'info', 0
cls_str db 'cls', 0
shut_str db 'shutdown', 0
reboot_str db 'reboot', 0

calc_str db 'calc', 0

; ============================= EXECUTE =============================
do_help:
    call print_help
    ret

do_info:
    call print_info
    ret

do_cls:
    pusha
    mov ax, 0x12
    int 0x10
    popa
    ret


do_shutdown:
    mov ax, 0x5307
    mov bx, 0x0001
    mov cx, 0x0003
    int 0x15
    ret

; START APPS
start_calc:
    pusha
    mov ah, 0x02
    mov al, 2       ; Количество секторов для чтения
    mov ch, 0       ; Номер дорожки
    mov dh, 0       ; Номер головки
    mov cl, 6       ; Номер сектора
    mov bx, 800h    ; Адрес загрузки
    int 0x13
    jc .disk_error  ; Если ошибка, перейти к обработке
    jmp 800h        ; Переход к загруженной программе
.disk_error:
    call print_newline
    mov si, errorSectorLabel
    call print_string_green
    popa
    ret

do_reboot:
    int 0x19
    ret

header db '=============================== IRION v.1.0.0 ==================================', 0
inputAdd db 'IRION > ', 0

errorSectorLabel db "Load Error", 0
startPrint  db "Welcome to IRION v.1.0.0", 13, 10,
            db "Please, enter 'help' to get help-list", 13, 10, 0  
menu db 0xC9, 47 dup(0xCD), 0xBB, 10, 13
     db 0xBA, ' Commands:                                     ', 0xBA, 10, 13
     db 0xBA, '  help - get list of the commands              ', 0xBA, 10, 13
     db 0xBA, '  cls - clear terminal                         ', 0xBA, 10, 13
     db 0xBA, '  shut - shutdown PC                           ', 0xBA, 10, 13
     db 0xBA, '  reboot - restart system                      ', 0xBA, 10, 13
     db 0xC0, 47 dup(0xCD), 0xBC, 10, 13, 0

info db 10, 13
     db 0xC9, 51 dup(0xCD), 0xBB, 10, 13
     db 0xBA, '  IRION OS is the simple 16 bit operating          ', 0xBA, 10, 13
     db 0xBA, '  system written in NASM for x86 PC`s              ', 0xBA, 10, 13
     db 0xC3, 51 dup(0xC4), 0xB4, 10, 13
     db 0xBA, '  Autor: filcher (https://github.com/filcherock)   ', 0xBA, 10, 13
     db 0xBA, '  Repository: https://github.com/filcherock/irion  ', 0xBA, 10, 13   
     db 0xBA, '  Video mode: 0x12 (640x480; 16 colors)            ', 0xBA, 10, 13
     db 0xBA, '  License: GNU General Public License v.3.0        ', 0xBA, 10, 13
     db 0xBA, '  OS version: 1.0.0                                ', 0xBA, 10, 13
     db 0xC0, 51 dup(0xCD), 0xBC, 10, 13
     db 0

; ============================= COMMANDS =============================

buffer db 512 dup(0)
command_buffer db 256 dup(0)