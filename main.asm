default rel

extern GetStdHandle
extern WriteConsoleA
extern ReadConsoleA
extern ExitProcess

; ========================================================
; Cajero Automático NASM x64 para Windows (Visual Studio)
; Funcionalidades:
; - Validación de PIN
; - Menú principal
; - Consultar saldo
; - Depositar
; - Retirar
; - Validación de entradas y manejo de errores
; Convención Windows x64: rcx, rdx, r8, r9 para parámetros
; ========================================================

section .data
    ; Saldo inicial y PIN correcto
    saldo dq 1000
    pin_correcto dq 1234

    ; Mensajes del programa
    msg_prompt db "Seleccione una opcion:",13,10
    len_prompt equ $ - msg_prompt

    msg_menu db "1. Saldo",13,10,"2. Depositar",13,10,"3. Retirar",13,10,"4. Salir",13,10
    len_menu equ $ - msg_menu

    msg_pin db "Ingrese PIN: ",13,10
    len_pin equ $ - msg_pin

    msg_error db "Fondos insuficientes",13,10
    len_error equ $ - msg_error

    msg_ok db "Operacion realizada",13,10
    len_ok equ $ - msg_ok

    msg_opcion_invalida db "Opcion invalida",13,10
    len_opcion_invalida equ $ - msg_opcion_invalida

    msg_entrada_invalida db "Entrada invalida",13,10
    len_entrada_invalida equ $ - msg_entrada_invalida

section .bss
    ; Variables de trabajo en memoria
    hConsole resq 1
    buffer resb 32
    read resd 1
    written resd 1
    numero resq 1

section .text
global main

; ========================
; Imprime un texto en consola usando WriteConsoleA
; Parámetros:
;   rcx = handle de consola
;   rdx = puntero al texto
;   r8d = longitud del texto
;   r9  = puntero a DWORD de caracteres escritos
; ========================
print:
    mov rcx, [hConsole]
    sub rsp, 40
    call WriteConsoleA
    add rsp, 40
    ret

; ========================
; Lee una línea de la consola en buffer
; ========================
leer:
    mov rcx, [hConsole]
    lea rdx, [buffer]
    mov r8d, 32
    lea r9, [read]

    sub rsp, 40
    call ReadConsoleA
    add rsp, 40
    ret

; ========================
; Convierte ASCII en buffer a entero
; Retorna:
;   RAX = -2 si la entrada está vacía
;   RAX = -1 si aparece un carácter no válido
;   RAX = número convertido si es válido
; ========================
convertir:
    xor rax, rax        ; acumulador del número
    xor rbx, rbx        ; índice de lectura en buffer
    xor rdx, rdx        ; contador de dígitos

.convertir_loop:
    movzx rcx, byte [buffer + rbx]
    cmp cl, 13          ; CR indica fin de línea
    je .fin_convertir

    cmp cl, '0'
    jl .invalid_digit
    cmp cl, '9'
    jg .invalid_digit

    sub rcx, '0'
    imul rax, rax, 10
    add rax, rcx

    inc rbx
    inc rdx
    cmp rbx, 32
    jl .convertir_loop

.invalid_digit:
    mov rax, -1
    ret

.fin_convertir:
    cmp rdx, 0
    jne .done_convertir
    mov rax, -2
    ret

.done_convertir:
    ret

; ========================
; Convierte un entero en buffer ASCII y retorna longitud
; ========================
imprimir_numero:
    mov r10, 10
    xor rcx, rcx
    lea r11, [buffer + 31]

    cmp rax, 0
    jne .conv_num

    ; Caso especial: número 0
    mov byte [buffer], '0'
    mov byte [buffer + 1], 13
    mov byte [buffer + 2], 10
    mov eax, 3
    ret

.conv_num:
    xor rdx, rdx
.conv_loop_num:
    div r10
    add dl, '0'
    dec r11
    mov [r11], dl
    inc rcx
    test rax, rax
    jnz .conv_loop_num

    lea rsi, [buffer]
.copy_num:
    mov dl, [r11]
    mov [rsi], dl
    inc rsi
    inc r11
    dec rcx
    jnz .copy_num

    mov byte [rsi], 13
    inc rsi
    mov byte [rsi], 10
    inc rsi

    mov rdx, rsi
    lea rax, [buffer]
    sub rdx, rax
    mov rax, rdx
    ret

; ========================
; MAIN
; ========================
main:
    ; Obtener el handle de la consola y guardarlo para uso posterior
    mov ecx, -11
    sub rsp, 40
    call GetStdHandle
    add rsp, 40
    mov [hConsole], rax

; ========================
; VALIDAR PIN
; ========================
validar_pin:
    lea rdx, [msg_pin]
    mov r8d, len_pin
    lea r9, [written]
    call print

    call leer
    call convertir
    cmp rax, -2
    je validar_pin
    cmp rax, -1
    je validar_pin

    mov [numero], rax
    mov rax, [numero]
    cmp rax, [pin_correcto]
    jne validar_pin

; ========================
; MENÚ PRINCIPAL
; ========================
menu:
    lea rdx, [msg_prompt]
    mov r8d, len_prompt
    lea r9, [written]
    call print

    lea rdx, [msg_menu]
    mov r8d, len_menu
    lea r9, [written]
    call print

    call leer
    call convertir
    cmp rax, -2
    je menu               ; entrada vacía: volver a mostrar menú
    cmp rax, -1
    je error_opcion       ; caracteres inválidos: mostrar mensaje

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

; ========================
; CONSULTAR SALDO
; ========================
consultar:
    mov rax, [saldo]
    call imprimir_numero

    mov rcx, [hConsole]
    lea rdx, [buffer]
    mov r8d, eax
    lea r9, [written]
    sub rsp, 40
    call WriteConsoleA
    add rsp, 40

    jmp menu

; ========================
; DEPOSITAR
; ========================
depositar:
    call leer
    call convertir
    cmp rax, -2
    je input_error
    cmp rax, -1
    je input_error

    mov [numero], rax
    mov rax, [saldo]
    add rax, [numero]
    mov [saldo], rax

    lea rdx, [msg_ok]
    mov r8d, len_ok
    lea r9, [written]
    call print

    jmp menu

; ========================
; RETIRAR
; ========================
retirar:
    call leer
    call convertir
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

    lea rdx, [msg_ok]
    mov r8d, len_ok
    lea r9, [written]
    call print

    jmp menu

; ========================
; ERROR: OPCIÓN INVÁLIDA
; ========================
error_opcion:
    lea rdx, [msg_opcion_invalida]
    mov r8d, len_opcion_invalida
    lea r9, [written]
    call print
    jmp menu

; ========================
; ERROR: ENTRADA INVÁLIDA
; ========================
input_error:
    lea rdx, [msg_entrada_invalida]
    mov r8d, len_entrada_invalida
    lea r9, [written]
    call print
    jmp menu

; ========================
; ERROR: FONDOS INSUFICIENTES
; ========================
error_fondos:
    lea rdx, [msg_error]
    mov r8d, len_error
    lea r9, [written]
    call print
    jmp menu

; ========================
; SALIR
; ========================
salir:
    sub rsp, 40
    xor ecx, ecx
    call ExitProcess