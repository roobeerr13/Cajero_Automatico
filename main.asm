default rel

extern GetStdHandle
extern WriteConsoleA
extern ReadConsoleA
extern ExitProcess

section .data
    ; =========================
    ; DATOS
    ; =========================
    msg_pin db "Ingrese PIN: ", 13, 10
    len_pin equ $ - msg_pin

    msg_menu db "1. Saldo  2. Depositar  3. Salir", 13, 10
    len_menu equ $ - msg_menu

    msg_saldo db "Saldo: ", 13, 10
    len_saldo equ $ - msg_saldo

    saldo dq 5              ; saldo inicial (1 digito)
    pin_correcto dq 1234


section .bss
    ; =========================
    ; VARIABLES
    ; =========================
    hConsole resq 1
    buffer resb 32
    bytesRead resd 1
    bytesWritten resd 1
    numero resq 1


section .text
    global main

; =========================
; MAIN
; =========================
main:

; =============================
; VALIDAR PIN
; =============================
validar_pin:

    ; Obtener consola salida
    mov ecx, -11
    sub rsp, 40
    call GetStdHandle
    add rsp, 40
    mov [hConsole], rax

    ; Mostrar mensaje PIN
    mov rcx, [hConsole]
    lea rdx, [msg_pin]
    mov r8d, len_pin
    lea r9, [bytesWritten]

    sub rsp, 40
    call WriteConsoleA
    add rsp, 40

    ; Leer input
    mov ecx, -10
    sub rsp, 40
    call GetStdHandle
    add rsp, 40
    mov [hConsole], rax

    mov rcx, [hConsole]
    lea rdx, [buffer]
    mov r8d, 32
    lea r9, [bytesRead]

    sub rsp, 40
    call ReadConsoleA
    add rsp, 40

    ; Convertir ASCII → entero
    xor rax, rax
    xor rbx, rbx

convert_pin:
    movzx rcx, byte [buffer + rbx]
    cmp rcx, 13
    je fin_convert_pin

    sub rcx, '0'
    imul rax, rax, 10
    add rax, rcx

    inc rbx
    jmp convert_pin

fin_convert_pin:

    cmp rax, [pin_correcto]
    jne validar_pin


; =============================
; MENU
; =============================
menu:

    ; Mostrar menu
    mov ecx, -11
    sub rsp, 40
    call GetStdHandle
    add rsp, 40
    mov [hConsole], rax

    mov rcx, [hConsole]
    lea rdx, [msg_menu]
    mov r8d, len_menu
    lea r9, [bytesWritten]

    sub rsp, 40
    call WriteConsoleA
    add rsp, 40

    ; Leer opcion
    mov ecx, -10
    sub rsp, 40
    call GetStdHandle
    add rsp, 40
    mov [hConsole], rax

    mov rcx, [hConsole]
    lea rdx, [buffer]
    mov r8d, 32
    lea r9, [bytesRead]

    sub rsp, 40
    call ReadConsoleA
    add rsp, 40

    ; Convertir opcion
    xor rax, rax
    movzx rax, byte [buffer]
    sub rax, '0'

    cmp rax, 1
    je consultar

    cmp rax, 2
    je depositar

    cmp rax, 3
    je salir

    jmp menu


; =============================
; CONSULTAR SALDO
; =============================
consultar:

    ; Mostrar texto
    mov rcx, [hConsole]
    lea rdx, [msg_saldo]
    mov r8d, len_saldo
    lea r9, [bytesWritten]

    sub rsp, 40
    call WriteConsoleA
    add rsp, 40

    ; Convertir saldo (solo 1 dígito)
    mov rax, [saldo]
    add rax, '0'
    mov [buffer], al

    ; Mostrar saldo
    mov rcx, [hConsole]
    lea rdx, [buffer]
    mov r8d, 2
    lea r9, [bytesWritten]

    sub rsp, 40
    call WriteConsoleA
    add rsp, 40

    jmp menu


; =============================
; DEPOSITAR
; =============================
depositar:

    ; Leer monto
    mov ecx, -10
    sub rsp, 40
    call GetStdHandle
    add rsp, 40
    mov [hConsole], rax

    mov rcx, [hConsole]
    lea rdx, [buffer]
    mov r8d, 32
    lea r9, [bytesRead]

    sub rsp, 40
    call ReadConsoleA
    add rsp, 40

    ; Convertir monto
    xor rax, rax
    xor rbx, rbx

convert_dep:
    movzx rcx, byte [buffer + rbx]
    cmp rcx, 13
    je fin_dep

    sub rcx, '0'
    imul rax, rax, 10
    add rax, rcx

    inc rbx
    jmp convert_dep

fin_dep:

    add [saldo], rax

    jmp menu


; =============================
; SALIR
; =============================
salir:
    xor ecx, ecx
    sub rsp, 40
    call ExitProcess