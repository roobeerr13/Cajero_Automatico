default rel

extern GetStdHandle
extern WriteConsoleA
extern ExitProcess

section .data
    numero dq 1234

    msg db "Numero convertido: ", 13, 10
    msg_len equ $ - msg

section .bss
    hConsole resq 1
    buffer resb 32
    bytesWritten resd 1

section .text
    global main

main:

    ; Obtener handle consola
    mov ecx, -11
    sub rsp, 40
    call GetStdHandle
    add rsp, 40
    mov [hConsole], rax

    ; Imprimir mensaje
    mov rcx, [hConsole]
    lea rdx, [msg]
    mov r8d, msg_len
    lea r9, [bytesWritten]
    sub rsp, 40
    call WriteConsoleA
    add rsp, 40

    ; ==========================
    ; CONVERSION ENTERO → ASCII
    ; ==========================

    mov rax, [numero]      ; número a convertir
    mov rcx, 10

    lea rdi, [buffer+31]   ; empezar desde el final
    mov byte [rdi], 0      ; terminador

convert_loop:
    xor rdx, rdx           ; limpiar rdx
    div rcx                ; rax = rax / 10, rdx = residuo

    add dl, '0'            ; convertir a ASCII
    dec rdi
    mov [rdi], dl

    test rax, rax
    jnz convert_loop

    ; ==========================
    ; IMPRIMIR RESULTADO
    ; ==========================

    mov rcx, [hConsole]
    mov rdx, rdi           ; puntero al inicio del número

    ; calcular longitud
    lea rbx, [buffer+31]
    sub rbx, rdi           ; longitud = final - inicio

    mov r8, rbx
    lea r9, [bytesWritten]

    sub rsp, 40
    call WriteConsoleA
    add rsp, 40

    ; ==========================
    ; SALIR
    ; ==========================

    xor ecx, ecx
    sub rsp, 40
    call ExitProcess