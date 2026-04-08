default rel

extern GetStdHandle
extern WriteConsoleA
extern ReadConsoleA
extern ExitProcess

section .data
    ; =========================
    ; DATOS
    ; =========================

    pin_correcto dq 1234

    msg_bienvenida db "=== CAJERO AUTOMATICO ===", 13, 10
    len_bienvenida equ $ - msg_bienvenida

    msg_pin db "Ingrese PIN: ", 13, 10
    len_pin equ $ - msg_pin

    msg_error db "PIN incorrecto", 13, 10
    len_error equ $ - msg_error


section .bss
    ; =========================
    ; VARIABLES
    ; =========================

    hConsoleOut resq 1
    hConsoleIn  resq 1

    buffer      resb 32
    bytesRead   resd 1
    bytesWritten resd 1


section .text
    global main

; =========================
; MAIN
; =========================
main:

    ; Obtener handle salida (STD_OUTPUT_HANDLE = -11)
    mov ecx, -11
    sub rsp, 40
    call GetStdHandle
    add rsp, 40
    mov [hConsoleOut], rax

    ; Obtener handle entrada (STD_INPUT_HANDLE = -10)
    mov ecx, -10
    sub rsp, 40
    call GetStdHandle
    add rsp, 40
    mov [hConsoleIn], rax

    ; Mostrar bienvenida
    mov rcx, [hConsoleOut]
    lea rdx, [msg_bienvenida]
    mov r8d, len_bienvenida
    lea r9, [bytesWritten]
    sub rsp, 40
    call WriteConsoleA
    add rsp, 40

    ; Ir a validación de PIN
    jmp validar_pin


; =========================
; VALIDACIÓN DE PIN
; =========================
validar_pin:

    ; Mostrar mensaje PIN
    mov rcx, [hConsoleOut]
    lea rdx, [msg_pin]
    mov r8d, len_pin
    lea r9, [bytesWritten]
    sub rsp, 40
    call WriteConsoleA
    add rsp, 40

    ; Leer entrada
    mov rcx, [hConsoleIn]
    lea rdx, [buffer]
    mov r8d, 32
    lea r9, [bytesRead]
    sub rsp, 40
    call ReadConsoleA
    add rsp, 40

    ; Convertir ASCII → entero
    xor rax, rax        ; resultado
    xor rbx, rbx        ; índice

convert_loop:

    movzx rcx, byte [buffer + rbx]

    cmp rcx, 13         ; ENTER
    je fin_conversion

    sub rcx, '0'
    imul rax, rax, 10
    add rax, rcx

    inc rbx
    jmp convert_loop

fin_conversion:

    ; Comparar con PIN correcto
    cmp rax, [pin_correcto]
    jne pin_error

    ; PIN correcto → (de momento) salir
    jmp salir


pin_error:

    ; Mostrar error
    mov rcx, [hConsoleOut]
    lea rdx, [msg_error]
    mov r8d, len_error
    lea r9, [bytesWritten]
    sub rsp, 40
    call WriteConsoleA
    add rsp, 40

    jmp validar_pin


; =========================
; SALIDA
; =========================
salir:
    xor ecx, ecx
    sub rsp, 40
    call ExitProcess