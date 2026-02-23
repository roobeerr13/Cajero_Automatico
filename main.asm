section .text

; Declaramos la función principal

global main

main:
    ; Reservamos 32 bytes de shadow space
    sub rsp, 40

    ; Llamamos a ExitProcess con código de salida 0
    mov rax, 0
    call ExitProcess
