[BITS 16]
[ORG 800h]

jmp start

%include "lib/ic32.inc"
%include "lib/utils.inc"

start:
    mov ax, 0x0003   ; Установить текстовый режим 80x25
    int 0x10

    ; Установка цвета текста и фона
    mov ah, 0x0E     ; Функция: вывод символа с атрибутом
    mov al, ' '      ; Символ пробела для заполнения фона
    mov bh, 0        ; Номер страницы (обычно 0)
    mov bl, 0x1F     ; Атрибут (синий фон, белый текст)

    ; Заполнение экрана пробелами для изменения фона
    mov cx, 2000     ; Количество символов (80 * 25)
    int 0x10

    mov dl, 0 
    mov dh, 0
    call set_cursor_pos

    call print_newline
    mov si, errorLabel
    call print_string_red

    call print_newline
    mov si, information
    call print_string

errorLabel db ' `7MM"""YMM  `7MM"""Mq.  `7MM"""Mq.    .g8""8q.   `7MM"""Mq.   ', 13, 10
           db '   MM    `7    MM   `MM.   MM   `MM. .dP*    `YM.   MM   `MM.  ', 13, 10 
           db '   MM   d      MM   ,M9    MM   ,M9  dM*      `MM   MM   ,M9   ', 13, 10
           db '   MMmmMM      MMmmdM9     MMmmdM9   MM        MM   MMmmdM9    ', 13, 10
           db '   MM   Y  ,   MM  YM.     MM  YM.   MM.      ,MP   MM  YM.    ', 13, 10  
           db '   MM     ,M   MM   `Mb.   MM   `Mb. `Mb.    ,dP*   MM   `Mb.  ', 13, 10
           db '  .JMMmmmmMMM .JMML. .JMM..JMML. .JMM.  `"bmmd"   .JMML. .JMM.', 13, 10, 0

information db "Oops! A critical error has occurred. Don't panic, nothing terrible has happened. You can contact the creator of Irion OS and discuss this problem", 0