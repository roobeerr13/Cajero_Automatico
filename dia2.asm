default rel

extern GetStdHandle
extern WriteConsoleA
extern ExitProcess

section .data
    mensaje db "Hola, este es el Dia 2!", 13, 10
    msg_len equ $ - mensaje

section .bss
    hConsole    resq 1
    written     resd 1

section .text
global main

main:

    ; Obtener handle de salida (STD_OUTPUT_HANDLE = -11)
    mov ecx, -11
    sub rsp, 40
    call GetStdHandle
    add rsp, 40

    mov [hConsole], rax

    ; Llamar WriteConsoleA
    mov rcx, [hConsole]
    lea rdx, [mensaje]
    mov r8d, msg_len
    lea r9, [written]

    sub rsp, 40
    call WriteConsoleA
    add rsp, 40

    ; Salir
    xor ecx, ecx
    sub rsp, 40
    call ExitProcess