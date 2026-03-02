default rel

extern GetStdHandle
extern ReadConsoleA
extern ExitProcess

global main

section .bss
align 8
buffer:    resb 64        
bytesRead: resd 1         

section .text

main:
    sub rsp, 40
    mov ecx, -10          
    call GetStdHandle
    add rsp, 40
    mov rcx, rax                  ; handle desde GetStdHandle
    lea rdx, [rel buffer]         ; dirección del buffer (relativo)
    mov r8d, 64                   ; leer hasta 64 caracteres
    lea r9, [rel bytesRead]       ; dirección de la variable bytesRead

    sub rsp, 40                   ; reservar shadow space (32) + 8 extra
    mov qword [rsp+32], 0         ; 5º argumento = NULL (se coloca tras el shadow)
    call ReadConsoleA
    add rsp, 40
    sub rsp, 40
    xor ecx, ecx                  ; código de salida = 0
    call ExitProcess
