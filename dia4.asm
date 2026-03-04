default rel

extern GetStdHandle
extern ExitProcess

section .data
    hConsole dq 0

section .text
    global main

main:

    ; ---------------------------------------
    ; GetStdHandle(STD_OUTPUT_HANDLE)
    ; STD_OUTPUT_HANDLE = -11
    ; ---------------------------------------

    mov rcx, -11        ; Primer parámetro en rcx

    sub rsp, 40         ; 32 bytes shadow + 8 alineación
    call GetStdHandle
    add rsp, 40

    ; El valor de retorno está en rax
    mov [hConsole], rax

    ; ---------------------------------------
    ; Salir del programa
    ; ExitProcess(0)
    ; ---------------------------------------

    xor rcx, rcx        ; Código de salida = 0

    sub rsp, 40
    call ExitProcess