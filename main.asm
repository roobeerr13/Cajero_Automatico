default rel

extern GetStdHandle
extern WriteConsoleA
extern ReadConsoleA
extern ExitProcess

section .data
    msg_menu db "1. Consultar saldo", 13, 10, "2. Depositar", 13, 10, "3. Retirar", 13, 10, "4. Salir", 13, 10, "Seleccione opcion: ", 0
    len_menu equ $ - msg_menu

    msg_saldo_actual db "Saldo actual: ", 0
    len_saldo_actual equ $ - msg_saldo_actual

    msg_ingrese_deposito db "Ingrese monto a depositar:", 13, 10, 0
    len_ingrese_deposito equ $ - msg_ingrese_deposito

    msg_deposito_realizado db "Deposito realizado", 13, 10, 0
    len_deposito_realizado equ $ - msg_deposito_realizado

    msg_ingrese_retiro db "Ingrese monto a retirar:", 13, 10, 0
    len_ingrese_retiro equ $ - msg_ingrese_retiro

    msg_retiro_realizado db "Retiro realizado", 13, 10, 0
    len_retiro_realizado equ $ - msg_retiro_realizado

    msg_fondos_insuficientes db "Fondos insuficientes", 13, 10, 0
    len_fondos_insuficientes equ $ - msg_fondos_insuficientes

    saldo dq 1000

section .bss
    hStdOut resq 1
    hStdIn resq 1
    buffer resb 32
    digits resb 32
    monto resq 1
    bytesRead resd 1
    bytesWritten resd 1

section .text
    global main

main:
    ; Obtener handles de entrada y salida de consola
    mov ecx, -11                  ; STD_OUTPUT_HANDLE
    sub rsp, 40
    call GetStdHandle
    add rsp, 40
    mov [hStdOut], rax

    mov ecx, -10                  ; STD_INPUT_HANDLE
    sub rsp, 40
    call GetStdHandle
    add rsp, 40
    mov [hStdIn], rax

menu:
    ; Mostrar menu principal
    mov rcx, [hStdOut]
    lea rdx, [msg_menu]
    mov r8d, len_menu
    lea r9, [bytesWritten]
    sub rsp, 40
    call WriteConsoleA
    add rsp, 40

    ; Leer opción del usuario
    mov rcx, [hStdIn]
    lea rdx, [buffer]
    mov r8d, 32
    lea r9, [bytesRead]
    sub rsp, 40
    call ReadConsoleA
    add rsp, 40

    ; Convertir opción ASCII → entero
    movzx rax, byte [buffer]
    sub rax, '0'

    cmp rax, 1
    je consultar
    cmp rax, 2
    je depositar
    cmp rax, 3
    je retirar
    cmp rax, 4
    je salir

    jmp menu

consultar:
    ; Mostrar mensaje de saldo
    mov rcx, [hStdOut]
    lea rdx, [msg_saldo_actual]
    mov r8d, len_saldo_actual
    lea r9, [bytesWritten]
    sub rsp, 40
    call WriteConsoleA
    add rsp, 40

    call mostrar_saldo
    jmp menu

depositar:
    ; Mostrar prompt de depósito
    mov rcx, [hStdOut]
    lea rdx, [msg_ingrese_deposito]
    mov r8d, len_ingrese_deposito
    lea r9, [bytesWritten]
    sub rsp, 40
    call WriteConsoleA
    add rsp, 40

    ; Leer monto ingresado por el usuario
    mov rcx, [hStdIn]
    lea rdx, [buffer]
    mov r8d, 32
    lea r9, [bytesRead]
    sub rsp, 40
    call ReadConsoleA
    add rsp, 40

    ; Convertir ASCII → entero usando resultado = resultado * 10 + (digito - '0')
    xor rax, rax
    xor rbx, rbx

convert_deposito:
    movzx rcx, byte [buffer + rbx]
    cmp rcx, 13
    je fin_convert_deposito
    sub rcx, '0'
    imul rax, rax, 10
    add rax, rcx
    inc rbx
    jmp convert_deposito

fin_convert_deposito:
    mov [monto], rax
    add [saldo], rax

    mov rcx, [hStdOut]
    lea rdx, [msg_deposito_realizado]
    mov r8d, len_deposito_realizado
    lea r9, [bytesWritten]
    sub rsp, 40
    call WriteConsoleA
    add rsp, 40

    call mostrar_saldo
    jmp menu

retirar:
    ; Mostrar prompt para retirar
    mov rcx, [hStdOut]
    lea rdx, [msg_ingrese_retiro]
    mov r8d, len_ingrese_retiro
    lea r9, [bytesWritten]
    sub rsp, 40
    call WriteConsoleA
    add rsp, 40

    ; Leer monto ingresado por el usuario
    mov rcx, [hStdIn]
    lea rdx, [buffer]
    mov r8d, 32
    lea r9, [bytesRead]
    sub rsp, 40
    call ReadConsoleA
    add rsp, 40

    ; Convertir ASCII → entero usando resultado = resultado * 10 + (digito - '0')
    xor rax, rax
    xor rbx, rbx

convert_retiro:
    movzx rcx, byte [buffer + rbx]
    cmp rcx, 13
    je fin_convert_retiro
    sub rcx, '0'
    imul rax, rax, 10
    add rax, rcx
    inc rbx
    jmp convert_retiro

fin_convert_retiro:
    mov [monto], rax

    ; Comparar monto con saldo para evitar saldo negativo
    mov rdx, [saldo]
    cmp rdx, rax
    jl error_fondos        ; si monto > saldo saltar a error

    ; Hay suficiente saldo, restar monto
    sub [saldo], rax

    mov rcx, [hStdOut]
    lea rdx, [msg_retiro_realizado]
    mov r8d, len_retiro_realizado
    lea r9, [bytesWritten]
    sub rsp, 40
    call WriteConsoleA
    add rsp, 40

    call mostrar_saldo
    jmp menu

error_fondos:
    ; Mostrar mensaje de error cuando no hay fondos suficientes
    mov rcx, [hStdOut]
    lea rdx, [msg_fondos_insuficientes]
    mov r8d, len_fondos_insuficientes
    lea r9, [bytesWritten]
    sub rsp, 40
    call WriteConsoleA
    add rsp, 40
    jmp menu

mostrar_saldo:
    ; Copiar saldo a RAX para no perder el valor original
    mov rax, [saldo]
    cmp rax, 0
    jne .conv_saldo_zero

    ; Si el saldo es 0, escribir "0" directamente
    mov byte [buffer], '0'
    mov byte [buffer+1], 13
    mov byte [buffer+2], 10
    mov rcx, [hStdOut]
    lea rdx, [buffer]
    mov r8d, 3
    lea r9, [bytesWritten]
    sub rsp, 40
    call WriteConsoleA
    add rsp, 40
    ret

.conv_saldo_zero:
    lea rsi, [digits]
    xor rcx, rcx
    mov rbx, 10

    ; Dividir repetidamente entre 10 para obtener residuos
.conv_digitos:
    xor rdx, rdx            ; limpiar RDX antes de DIV
    div rbx                 ; RAX / 10 => cociente en RAX, residuo en RDX
    add dl, '0'             ; convertir residuo a ASCII
    mov [rsi + rcx], dl
    inc rcx
    test rax, rax
    jnz .conv_digitos

    ; Invertir el orden de los dígitos en el buffer de salida
    lea rdi, [buffer]
    mov r8, rcx
    dec r8
.reverse_digits:
    mov al, [rsi + r8]
    mov [rdi], al
    inc rdi
    dec r8
    jns .reverse_digits

    mov byte [rdi], 13
    inc rdi
    mov byte [rdi], 10
    inc rdi

    mov r9, rdi
    sub r9, buffer
    mov rcx, [hStdOut]
    lea rdx, [buffer]
    mov r8d, r9d
    lea r9, [bytesWritten]
    sub rsp, 40
    call WriteConsoleA
    add rsp, 40
    ret

salir:
    xor ecx, ecx
    sub rsp, 40
    call ExitProcess
