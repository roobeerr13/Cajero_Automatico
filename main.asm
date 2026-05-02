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
    intentos dq 3

    msg_pin db "Ingrese PIN: ",13,10
    len_pin equ $ - msg_pin

    msg_bloqueado db "Tarjeta bloqueada",13,10
    len_bloqueado equ $ - msg_bloqueado

    msg_prompt db "Seleccione una opcion:",13,10
    len_prompt equ $ - msg_prompt

    msg_menu db "1. Saldo",13,10,"2. Depositar",13,10,"3. Retirar",13,10,"4. Salir",13,10
    len_menu equ $ - msg_menu

    msg_saldo db "Saldo actual:",13,10
    len_saldo equ $ - msg_saldo

    msg_depositar db "Ingrese monto a depositar:",13,10
    len_depositar equ $ - msg_depositar

    msg_retirar db "Ingrese monto a retirar:",13,10
    len_retirar equ $ - msg_retirar

    msg_ok db "Operacion realizada",13,10
    len_ok equ $ - msg_ok

    msg_error_fondos db "Fondos insuficientes",13,10
    len_error_fondos equ $ - msg_error_fondos

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
    hInput resq 1

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
    mov rcx, [rel hConsole]
    lea r9, [rel written]
    call write_console
    ret

; ========================================================
; read_input: lee una linea de consola en el buffer
; ========================================================
read_input:
    mov rcx, [rel hConsole]
    lea rdx, [rel buffer]
    mov r8d, 32
    lea r9, [rel read]
    sub rsp, 40
    call ReadConsoleA
    add rsp, 40
    ret

; ========================================================
; ascii_to_int: convierte ASCII a entero
; Retorno:
;   RAX = -2 si la entrada está vacía
;   RAX = -1 si hay caracter inválido
;   RAX = valor convertido si es válido
; ========================================================
ascii_to_int:
    xor rax, rax
    xor rbx, rbx
    xor rdx, rdx

.loop:
    lea rsi, [rel buffer]
    movzx rcx, byte [rsi + rbx]
    cmp cl, 13
    je .fin

    cmp cl, '0'
    jl .error
    cmp cl, '9'
    jg .error

    sub rcx, '0'
    imul rax, rax, 10
    add rax, rcx

    inc rbx
    inc rdx
    cmp rbx, 32
    jl .loop

.error:
    mov rax, -1
    ret

.fin:
    cmp rdx, 0
    jne .ok
    mov rax, -2
    ret

.ok:
    ret

; ========================================================
; convert_int_to_ascii: convierte entero a ASCII en buffer
; Entrada:
;   RAX = entero no negativo
; Retorno:
;   RAX = longitud de texto escrita en buffer
; ========================================================
int_to_ascii:
    mov r10, 10
    xor rcx, rcx
    lea r11, [rel buffer + 31]

    cmp rax, 0
    jne .convert

    mov byte [buffer], '0'
    mov byte [buffer+1], 13
    mov byte [buffer+2], 10
    mov eax, 3
    ret

.convert:
.loop2:
    xor rdx, rdx
    div r10
    add dl, '0'
    dec r11
    mov [r11], dl
    inc rcx
    test rax, rax
    jnz .loop2

    lea rsi, [rel buffer]

.copy:
    mov dl, [r11]
    mov [rsi], dl
    inc rsi
    inc r11
    dec rcx
    jnz .copy

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
    call int_to_ascii
    mov rcx, [rel hConsole]
    lea rdx, [rel buffer]
    mov r8d, eax
    lea r9, [rel written]
    call write_console
    ret

; ========================================================
; MAIN
; ========================================================
main:
    ; OUTPUT (pantalla)
    mov ecx, -11
    sub rsp, 40
    call GetStdHandle
    add rsp, 40
    mov [rel hConsole], rax

    ; INPUT (teclado)
    mov ecx, -10
    sub rsp, 40
    call GetStdHandle
    add rsp, 40
    mov [rel hInput], rax

    jmp validar_pin

; ========================================================
; VALIDAR PIN
; ========================================================
validar_pin:
    cmp qword [rel intentos], 0
    je bloqueado

    mov rdx, msg_pin
    mov r8d, len_pin
    call display_message

    call read_input
    call ascii_to_int

    cmp rax, -2        ; entrada vacía
    je validar_pin     ; repetir sin penalizar

    cmp rax, [rel pin_correcto]
    je menu

    dec qword [rel intentos]
    jmp validar_pin

bloqueado:
    mov rdx, msg_bloqueado
    mov r8d, len_bloqueado
    call display_message

    jmp salir

; ========================================================
; MENÚ PRINCIPAL
; ========================================================
menu:
    mov rdx, msg_menu
    mov r8d, len_menu
    call display_message

    call read_input
    call ascii_to_int

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
    mov rdx, msg_saldo
    mov r8d, len_saldo
    call display_message

    mov rax, [rel saldo]
    call print_number
    jmp menu

; ========================================================
; DEPOSITAR
; ========================================================
depositar:
    mov rdx, msg_depositar
    mov r8d, len_depositar
    call display_message

    call read_input
    call ascii_to_int

    cmp rax, 0
    jle error_entrada

    add [rel saldo], rax

    mov rdx, msg_ok
    mov r8d, len_ok
    call display_message
    jmp menu

; ========================================================
; RETIRAR
; ========================================================
retirar:
    mov rdx, msg_retirar
    mov r8d, len_retirar
    call display_message

    call read_input
    call ascii_to_int

    cmp rax, 0
    jle error_entrada

    mov rbx, rax
    mov rax, [saldo]

    cmp rax, rbx
    jl error_fondos

    sub rax, rbx
    mov [rel saldo], rax

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

error_entrada:
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
