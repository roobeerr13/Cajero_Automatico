default rel

section .data
buffer_out times 32 db 0

; Declaramos la función principal

extern ExitProcess
extern GetStdHandle
extern WriteConsoleA

global main

main:
    sub rsp, 32

    ; obtener consola
    mov ecx, -11
    call GetStdHandle
    mov [hConsole], rax

    ; número de prueba
    mov rax, 1234

    ; convertir
    call convertir_entero_ascii

    mov rbx, rax

    ; calcular longitud
    mov rsi, rbx
.calcular:
    cmp byte [rsi], 0
    je .fin
    inc rsi
    jmp .calcular

.fin:
    sub rsi, rbx

    ; imprimir
    mov rcx, [hConsole]
    mov rdx, rbx
    mov r8, rsi
    lea r9, [bytesWritten]

    sub rsp, 40
    call WriteConsoleA
    add rsp, 40

    ; salir
    xor rcx, rcx
    call ExitProcess