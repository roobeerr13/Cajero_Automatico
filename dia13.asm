default rel

extern GetStdHandle
extern WriteConsoleA
extern ReadConsoleA
extern ExitProcess

global main

section .data
menuText db '--- MENU ---',0Dh,0Ah,0Ah
        db '1. Consultar saldo',0Dh,0Ah
        db '2. Depositar',0Dh,0Ah
        db '3. Retirar',0Dh,0Ah
        db '4. Salir',0Dh,0Ah,0Ah
        db 'Seleccione una opcion: '
menuLen equ $-menuText

consultMsg db 'Has seleccionado consultar saldo',0Dh,0Ah
consultLen equ $-consultMsg

depositMsg db 'Has seleccionado depositar',0Dh,0Ah
depositLen equ $-depositMsg

withdrawMsg db 'Has seleccionado retirar',0Dh,0Ah
withdrawLen equ $-withdrawMsg

section .bss
inputBuffer resb 16
charsRead   resd 1
charsWritten resd 1

section .text
main:
    ; Obtener los handles de entrada y salida estándar
    mov rcx, -11                    ; STD_OUTPUT_HANDLE
    sub rsp, 40                    ; reservar 32 bytes de shadow space + alineación
    call GetStdHandle
    add rsp, 40
    mov r12, rax                   ; guardar handle de salida en r12

    mov rcx, -10                    ; STD_INPUT_HANDLE
    sub rsp, 40
    call GetStdHandle
    add rsp, 40
    mov r13, rax                   ; guardar handle de entrada en r13

menu:
    ; Mostrar el menú principal
    mov rcx, r12
    lea rdx, [rel menuText]
    mov r8d, menuLen
    lea r9, [rel charsWritten]
    sub rsp, 40
    mov qword [rsp+32], 0          ; lpReserved = NULL
    call WriteConsoleA
    add rsp, 40

    ; Leer la opción del usuario (hasta 16 bytes)
    mov rcx, r13
    lea rdx, [rel inputBuffer]
    mov r8d, 16
    lea r9, [rel charsRead]
    sub rsp, 40
    mov qword [rsp+32], 0          ; lpReserved = NULL
    call ReadConsoleA
    add rsp, 40

    ; Convertir ASCII a entero (solo un dígito)
    movzx eax, byte [rel inputBuffer]
    sub eax, '0'

    cmp al, 1
    je consultar
    cmp al, 2
    je depositar
    cmp al, 3
    je retirar
    cmp al, 4
    je salir

    ; Si la opción no es válida, volver al menú
    jmp menu

consultar:
    ; Usuario eligió consultar saldo
    mov rcx, r12
    lea rdx, [rel consultMsg]
    mov r8d, consultLen
    lea r9, [rel charsWritten]
    sub rsp, 40
    mov qword [rsp+32], 0
    call WriteConsoleA
    add rsp, 40
    jmp menu

depositar:
    ; Usuario eligió depositar
    mov rcx, r12
    lea rdx, [rel depositMsg]
    mov r8d, depositLen
    lea r9, [rel charsWritten]
    sub rsp, 40
    mov qword [rsp+32], 0
    call WriteConsoleA
    add rsp, 40
    jmp menu

retirar:
    ; Usuario eligió retirar
    mov rcx, r12
    lea rdx, [rel withdrawMsg]
    mov r8d, withdrawLen
    lea r9, [rel charsWritten]
    sub rsp, 40
    mov qword [rsp+32], 0
    call WriteConsoleA
    add rsp, 40
    jmp menu

salir:
    ; Salir del programa con código 0
    xor ecx, ecx
    sub rsp, 40
    call ExitProcess
    add rsp, 40
