default rel

extern GetStdHandle
extern WriteConsoleA
extern ExitProcess

section .data
    message db "Hola desde NASM", 10, 0  ; 10 is newline, 0 null terminator (though not needed for WriteConsoleA)
    message_len equ $ - message         ; Length of the message including newline

section .text
    global main

print_string:
    sub rsp, 32

    mov rcx, -11        ; Primer parámetro: STD_OUTPUT_HANDLE
    call GetStdHandle   ; Llama a GetStdHandle, retorno en rax

    mov rcx, rax        ; hConsoleOutput en rcx
    ; rdx ya es lpBuffer
    mov r8, rdx         ; nNumberOfCharsToWrite en r8 (longitud original en rdx)
    xor r9, r9          ; lpNumberOfCharsWritten = NULL
    sub rsp, 8          ; Espacio para el 5to parámetro
    mov qword [rsp], 0  ; lpReserved = NULL
    call WriteConsoleA

    ; Restaurar el stack
    add rsp, 40         ; 32 shadow + 8 para el parámetro

    ret

main:
    ; Reservar shadow space para llamadas
    sub rsp, 32

    ; Llamar a print_string con el mensaje
    lea rcx, [message]      ; rcx = puntero al mensaje
    mov rdx, message_len    ; rdx = longitud del mensaje
    call print_string

    ; Terminar el programa con ExitProcess(0)
    xor rcx, rcx            ; Código de salida 0
    call ExitProcess