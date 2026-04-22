default rel

extern GetStdHandle
extern WriteConsoleA
extern ReadConsoleA
extern ExitProcess

section .data
    saldo dq 1000
    pin_correcto dq 1234

    msg_pin db "Ingrese PIN: ", 13, 10
    len_pin equ $ - msg_pin

    msg_menu db "1. Saldo",13,10,"2. Depositar",13,10,"3. Retirar",13,10,"4. Salir",13,10
    len_menu equ $ - msg_menu

    msg_error db "Fondos insuficientes",13,10
    len_error equ $ - msg_error

    msg_ok db "Operacion realizada",13,10
    len_ok equ $ - msg_ok

section .bss
    hConsole resq 1
    buffer resb 32
    read resd 1
    written resd 1
    numero resq 1

section .text
global main

; ========================
; FUNCION IMPRIMIR
; ========================
print:
    mov rcx, [hConsole]
    sub rsp, 40
    call WriteConsoleA
    add rsp, 40
    ret

; ========================
; FUNCION LEER
; ========================
leer:
    mov ecx, -10
    sub rsp, 40
    call GetStdHandle
    add rsp, 40
    mov [hConsole], rax

    mov rcx, [hConsole]
    lea rdx, [buffer]
    mov r8d, 32
    lea r9, [read]

    sub rsp, 40
    call ReadConsoleA
    add rsp, 40
    ret

; ========================
; ASCII → ENTERO
; ========================
convertir:
    xor rax, rax
    xor rbx, rbx

.loop:
    movzx rcx, byte [buffer + rbx]
    cmp rcx, 13
    je .fin

    sub rcx, '0'
    imul rax, rax, 10
    add rax, rcx

    inc rbx
    jmp .loop

.fin:
    mov [numero], rax
    ret

; ========================
; MAIN
; ========================
main:

    ; obtener consola salida
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

    mov rax, [numero]
    cmp rax, [pin_correcto]
    jne validar_pin

; ========================
; MENU
; ========================
menu:

    lea rdx, [msg_menu]
    mov r8d, len_menu
    lea r9, [written]
    call print

    call leer
    call convertir

    mov rax, [numero]

    cmp rax, 1
    je consultar

    cmp rax, 2
    je depositar

    cmp rax, 3
    je retirar

    cmp rax, 4
    je salir

    jmp menu

; ========================
; CONSULTAR SALDO
; ========================
consultar:
    mov rax, [saldo]
    add rax, '0'
    mov [buffer], al
    mov byte [buffer+1], 13
    mov byte [buffer+2], 10

    mov rcx, [hConsole]
    lea rdx, [buffer]
    mov r8d, 3
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

    mov rax, [saldo]
    cmp rax, [numero]
    jl error

    sub rax, [numero]
    mov [saldo], rax

    lea rdx, [msg_ok]
    mov r8d, len_ok
    lea r9, [written]
    call print

    jmp menu

; ========================
; ERROR
; ========================
error:
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