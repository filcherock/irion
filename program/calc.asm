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

    mov bp, wmsg
    mov cx, 80
    call print_textbar
    
    call print_newline

    mov si, start_label
    call print_string
    
    call calculator

calculator:
    mov ax, [step]
	cmp ax, 0
    je .step1
    cmp ax, 1
    je .step2
    cmp ax, 2
    je .step3
    cmp ax, 3
    je .result
.step1
    mov si, step1_label
    call print_string

    mov si, input_buffer
	mov bx, 4
	call scan_string
    call print_newline

    mov di, input_buffer
	mov bx, num1
	call convert_to_number
	
	mov al, [step]
	inc al
	mov [step], al

    jmp calculator
.step2
    mov si, step2_label
    call print_string

    mov si, input_buffer
	mov bx, 4
	call scan_string
    call print_newline

    mov di, input_buffer
	mov bx, num2
	call convert_to_number
	
	mov al, [step]
	inc al
	mov [step], al

    jmp calculator
.step3
    mov si, step3_label
    call print_string

    mov si, input_buffer
	mov bx, 4
	call scan_string
	call print_newline
	
	mov di, input_buffer
	mov bx, action
	call convert_to_number
	
	mov al, [step]
	inc al
	mov [step], al
	
	jmp calculator
.result
    mov ax, [action]
	cmp ax, 1
    call .actionPlus
.actionPlus
    mov ax, [num1]
	mov bx, [num2]
	add ax, bx
	mov di, result_label
	call convert_to_string
	
	mov si, result_label
	call print_string
	call print_newline

    mov al, [step]
	inc al
	mov [step], al
    
	jmp calculator



wmsg db 'Irion Calculator                                                                           ', 13,10,0
start_label db "Welcome to Irion Calculate!", 13, 10, 0
step1_label db "Please, enter first number: ", 0
step2_label db "Please, enter second number: ", 0
step3_label db "Please, enter action(+,-,*,/): ", 0

result_label db "Result: ", 0

action resw 1
step resw 1
input_buffer db 6 dup(0)
num1 resw 1
num2 resw 1
result_str db 7 dup(0)