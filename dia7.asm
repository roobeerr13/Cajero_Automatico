default rel

section .data
mensaje_entrada db "Ingrese un numero:", 0
mensaje_entrada_len equ $-mensaje_entrada
mensaje_exito db "Numero recibido correctamente", 0
mensaje_exito_len equ $-mensaje_exito

section .bss
buffer resb 64
num_leidos resd 1
numero resq 1

section .text
extern GetStdHandle
extern WriteConsoleA
extern ReadConsoleA
extern ExitProcess

global main
main:
    ; Reservamos shadow space y alineamos stack
    sub rsp, 40

    ; Mostrar prompt en consola
    mov ecx, -11              ; STD_OUTPUT_HANDLE
    call GetStdHandle
    mov r12, rax
    mov rcx, r12
    lea rdx, [mensaje_entrada]
    mov r8d, mensaje_entrada_len
    lea r9, [num_leidos]
    xor rax, rax
    call WriteConsoleA

    ; Leer entrada de usuario (hasta 64 bytes)
    mov ecx, -10              ; STD_INPUT_HANDLE
    call GetStdHandle
    mov rcx, rax
    lea rdx, [buffer]
    mov r8d, 64
    lea r9, [num_leidos]
    xor rax, rax
    call ReadConsoleA

    ; Convertir ASCII a entero
    xor rax, rax
    lea rsi, [buffer]
convert_loop:
    mov al, [rsi]
    cmp al, 13
    je convert_done
    cmp al, '0'
    jb convert_done
    cmp al, '9'
    ja convert_done
    mov rdx, rax
    shl rax, 1
    lea rax, [rax + rdx*4]
    movzx rdx, al
    sub rdx, '0'
    add rax, rdx
    inc rsi
    jmp convert_loop
convert_done:
    mov [numero], rax

    ; Mostrar mensaje de éxito
    mov rcx, r12
    lea rdx, [mensaje_exito]
    mov r8d, mensaje_exito_len
    lea r9, [num_leidos]
    xor rax, rax
    call WriteConsoleA

    ; Salir con código 0
    xor ecx, ecx
    call ExitProcess
