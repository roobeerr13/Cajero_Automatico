default rel

extern GetStdHandle
extern WriteConsoleA
extern ReadConsoleA
extern ExitProcess

section .data
    prompt db "Ingrese un numero:",13,10
    prompt_len equ $-prompt

section .bss
    hInput resq 1
    hOutput resq 1
    buffer resb 32
    bytesRead resd 1
    bytesWritten resd 1
    numero resq 1

section .text
    global main

main:

;--------------------------------
; Obtener handle de salida
;--------------------------------
    mov ecx, -11
    sub rsp,40
    call GetStdHandle
    add rsp,40
    mov [hOutput], rax

;--------------------------------
; Mostrar mensaje
;--------------------------------
    mov rcx,[hOutput]
    lea rdx,[prompt]
    mov r8d,prompt_len
    lea r9,[bytesWritten]
    sub rsp,40
    call WriteConsoleA
    add rsp,40

;--------------------------------
; Obtener handle de entrada
;--------------------------------
    mov ecx,-10
    sub rsp,40
    call GetStdHandle
    add rsp,40
    mov [hInput],rax

;--------------------------------
; Leer entrada del usuario
;--------------------------------
    mov rcx,[hInput]
    lea rdx,[buffer]
    mov r8d,32
    lea r9,[bytesRead]
    sub rsp,40
    call ReadConsoleA
    add rsp,40

;--------------------------------
; ASCII -> ENTERO
;--------------------------------

    xor rax,rax
    xor rbx,rbx

convert_loop:

    movzx rcx,byte [buffer+rbx]

    cmp rcx,13
    je conversion_done

    sub rcx,'0'

    imul rax,rax,10
    add rax,rcx

    inc rbx
    jmp convert_loop

conversion_done:

    mov [numero],rax

;--------------------------------
; Salir
;--------------------------------
    xor ecx,ecx
    sub rsp,40
    call ExitProcess