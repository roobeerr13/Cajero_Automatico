default rel

extern GetStdHandle
extern WriteConsoleA
extern ReadConsoleA
extern ExitProcess

; ========================================================
; Cajero Automático NASM x64 para Windows (Visual Studio)
; Funciones principales:
; - Validación de PIN
; - Menú principal
; - Consultar saldo
; - Depositar
; - Retirar
; - Validación de entradas y manejo de errores
; Convención Windows x64: rcx, rdx, r8, r9 para parámetros
; ========================================================

section .data
    saldo dq 1000
    pin_correcto dq 1234

    msg_prompt db "Seleccione una opcion:",13,10
    len_prompt equ $ - msg_prompt

    msg_menu db "1. Saldo",13,10,"2. Depositar",13,10,"3. Retirar",13,10,"4. Salir",13,10
    len_menu equ $ - msg_menu

    msg_pin db "Ingrese PIN: ",13,10
    len_pin equ $ - msg_pin

    msg_error_fondos db "Fondos insuficientes",13,10
    len_error_fondos equ $ - msg_error_fondos

    msg_ok db "Operacion realizada",13,10
    len_ok equ $ - msg_ok

    msg_error_opcion db "Opcion invalida",13,10
    len_error_opcion equ $ - msg_error_opcion

    msg_error_entrada db "Entrada invalida",13,10
    len_error_entrada equ $ - msg_error_entrada

section .bss
    hConsole resq 1
    buffer resb 32
    read resd 1
    written resd 1
    numero resq 1

section .text
global main

; ========================================================
; write_console: envuelve WriteConsoleA
; Entrada:
;   rcx = handle de consola
;   rdx = puntero al texto
;   r8d = longitud del texto
;   r9  = puntero a DWORD para caracteres escritos
; ========================================================
write_console:
    sub rsp, 40
    call WriteConsoleA
    add rsp, 40
    ret

; ========================================================
; display_message: imprime un mensaje en consola
; Entrada:
;   rdx = puntero al texto
;   r8d = longitud del texto
; ========================================================
display_message:
    mov rcx, [hConsole]
    lea r9, [written]
    call write_console
    ret

; ========================================================
; read_input: lee una linea de consola en el buffer
; ========================================================
read_input:
    mov rcx, [hConsole]
    lea rdx, [buffer]
    mov r8d, 32
    lea r9, [read]
    sub rsp, 40
    call ReadConsoleA
    add rsp, 40
    ret

; ========================================================
; convert_ascii_to_int: convierte ASCII a entero
; Retorno:
;   RAX = -2 si la entrada está vacía
;   RAX = -1 si hay caracter inválido
;   RAX = valor convertido si es válido
; ========================================================
convert_ascii_to_int:
    xor rax, rax
    xor rbx, rbx
    xor rdx, rdx

.convert_ascii_loop:
    movzx rcx, byte [buffer + rbx]
    cmp cl, 13
    je .finish_conversion

    cmp cl, '0'
    jl .invalid_input
    cmp cl, '9'
    jg .invalid_input

    sub rcx, '0'
    imul rax, rax, 10
    add rax, rcx

    inc rbx
    inc rdx
    cmp rbx, 32
    jl .convert_ascii_loop

.invalid_input:
    mov rax, -1
    ret

.finish_conversion:
    cmp rdx, 0
    jne .valid_number
    mov rax, -2
    ret

.valid_number:
    ret

; ========================================================
; convert_int_to_ascii: convierte entero a ASCII en buffer
; Entrada:
;   RAX = entero no negativo
; Retorno:
;   RAX = longitud de texto escrita en buffer
; ========================================================
convert_int_to_ascii:
    mov r10, 10
    xor rcx, rcx
    lea r11, [buffer + 31]

    cmp rax, 0
    jne .convert_positive

    mov byte [buffer], '0'
    mov byte [buffer + 1], 13
    mov byte [buffer + 2], 10
    mov eax, 3
    ret

.convert_positive:
    xor rdx, rdx

.convert_loop:
    div r10
    add dl, '0'
    dec r11
    mov [r11], dl
    inc rcx
    test rax, rax
    jnz .convert_loop

    lea rsi, [buffer]
.copy_loop:
    mov dl, [r11]
    mov [rsi], dl
    inc rsi
    inc r11
    dec rcx
    jnz .copy_loop

    mov byte [rsi], 13
    inc rsi
    mov byte [rsi], 10
    inc rsi

    lea rdx, [rsi]
    lea rax, [buffer]
    sub rdx, rax
    mov rax, rdx
    ret

; ========================================================
; print_number: convierte y muestra un entero en consola
; Entrada:
;   RAX = valor a mostrar
; ========================================================
print_number:
    call convert_int_to_ascii
    mov rcx, [hConsole]
    lea rdx, [buffer]
    mov r8d, eax
    lea r9, [written]
    call write_console
    ret

; ========================================================
; MAIN
; ========================================================
main:
    mov ecx, -11
    sub rsp, 40
    call GetStdHandle
    add rsp, 40
    mov [hConsole], rax

    jmp validar_pin

; ========================================================
; VALIDAR PIN
; ========================================================
validar_pin:
    mov rdx, msg_pin
    mov r8d, len_pin
    call display_message

    call read_input
    call convert_ascii_to_int
    cmp rax, -2
    je validar_pin
    cmp rax, -1
    je validar_pin

    cmp rax, [pin_correcto]
    jne validar_pin

    jmp menu

; ========================================================
; MENÚ PRINCIPAL
; ========================================================
menu:
    mov rdx, msg_prompt
    mov r8d, len_prompt
    call display_message

    mov rdx, msg_menu
    mov r8d, len_menu
    call display_message

    call read_input
    call convert_ascii_to_int
    cmp rax, -2
    je menu
    cmp rax, -1
    je error_opcion

    mov [numero], rax
    cmp rax, 1
    je consultar
    cmp rax, 2
    je depositar
    cmp rax, 3
    je retirar
    cmp rax, 4
    je salir

    jmp error_opcion

; ========================================================
; CONSULTAR SALDO
; ========================================================
consultar:
    mov rax, [saldo]
    call print_number
    jmp menu

; ========================================================
; DEPOSITAR
; ========================================================
depositar:
    call read_input
    call convert_ascii_to_int
    cmp rax, -2
    je input_error
    cmp rax, -1
    je input_error

    mov [numero], rax
    mov rax, [saldo]
    add rax, [numero]
    mov [saldo], rax

    mov rdx, msg_ok
    mov r8d, len_ok
    call display_message
    jmp menu

; ========================================================
; RETIRAR
; ========================================================
retirar:
    call read_input
    call convert_ascii_to_int
    cmp rax, -2
    je input_error
    cmp rax, -1
    je input_error

    mov [numero], rax
    mov rax, [saldo]
    cmp rax, [numero]
    jl error_fondos

    sub rax, [numero]
    mov [saldo], rax

    mov rdx, msg_ok
    mov r8d, len_ok
    call display_message
    jmp menu

; ========================================================
; ERRORES
; ========================================================
error_opcion:
    mov rdx, msg_error_opcion
    mov r8d, len_error_opcion
    call display_message
    jmp menu

input_error:
    mov rdx, msg_error_entrada
    mov r8d, len_error_entrada
    call display_message
    jmp menu

error_fondos:
    mov rdx, msg_error_fondos
    mov r8d, len_error_fondos
    call display_message
    jmp menu

; ========================================================
; SALIR
; ========================================================
salir:
    sub rsp, 40
    xor ecx, ecx
    call ExitProcess
