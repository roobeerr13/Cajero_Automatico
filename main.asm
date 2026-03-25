default rel

extern GetStdHandle
extern WriteConsoleA
extern ReadConsoleA
extern ExitProcess

; =========================
; 🔹 DATOS FIJOS
; =========================
section .data
    saldo dq 1000
    pin_correcto dq 1234

    msg db "Ingrese un numero: ", 13, 10
    msg_len equ $ - msg

    msg_resultado db "Numero convertido: ", 13, 10
    msg_res_len equ $ - msg_resultado

; =========================
; 🔹 VARIABLES
; =========================
section .bss
    hConsole resq 1
    buffer resb 32
    bytesRead resd 1
    bytesWritten resd 1
    numero resq 1

; =========================
; 🔹 CODIGO
; =========================
section .text
    global main

main:

    ; Mostrar mensaje
    call print_msg

    ; Leer entrada
    call leer_input

    ; Convertir ASCII → entero
    call ascii_to_int

    ; Mostrar resultado (solo 1 dígito simplificado)
    call mostrar_resultado

    ; Salir
    xor ecx, ecx
    sub rsp, 40
    call ExitProcess


; =========================
; 🔹 FUNCIONES
; =========================

print_msg:
    mov ecx, -11
    sub rsp, 40
    call GetStdHandle
    add rsp, 40
    mov [hConsole], rax

    mov rcx, [hConsole]
    lea rdx, [msg]
    mov r8d, msg_len
    lea r9, [bytesWritten]

    sub rsp, 40
    call WriteConsoleA
    add rsp, 40
    ret


leer_input:
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
    ret


ascii_to_int:
    xor rax, rax
    xor rbx, rbx

convert_loop:
    movzx rcx, byte [buffer + rbx]
    cmp rcx, 13         ; Enter
    je done

    sub rcx, '0'
    imul rax, rax, 10
    add rax, rcx

    inc rbx
    jmp convert_loop

done:
    mov [numero], rax
    ret


mostrar_resultado:

    ; Mostrar texto
    mov ecx, -11
    sub rsp, 40
    call GetStdHandle
    add rsp, 40
    mov [hConsole], rax

    mov rcx, [hConsole]
    lea rdx, [msg_resultado]
    mov r8d, msg_res_len
    lea r9, [bytesWritten]

    sub rsp, 40
    call WriteConsoleA
    add rsp, 40

    ; Mostrar número (solo 1 dígito demo)
    mov rax, [numero]
    add rax, '0'
    mov [buffer], al
    mov byte [buffer+1], 13
    mov byte [buffer+2], 10

    mov rcx, [hConsole]
    lea rdx, [buffer]
    mov r8d, 3
    lea r9, [bytesWritten]

    sub rsp, 40
    call WriteConsoleA
    add rsp, 40

    ret