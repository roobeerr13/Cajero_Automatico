default rel

section .data
    mensaje_entrada db "Ingrese un numero:", 0
    mensaje_entrada_len equ $-mensaje_entrada

    mensaje_convertido db "Numero convertido:", 0
    mensaje_convertido_len equ $-mensaje_convertido

section .bss
    buffer resb 64            ; buffer de lectura de texto
    num_leidos resd 1         ; almacenará bytes leídos
    numero resq 1             ; valor entero convertido

    outbuf resb 32            ; buffer de dígitos convertidos (inverso)
    finalbuf resb 66          ; buffer final para texto con CR LF
    final_len resd 1

section .text
    extern GetStdHandle
    extern WriteConsoleA
    extern ReadConsoleA
    extern ExitProcess

    global main

main:
    ; Reserva shadow space y alinea stack (necesario en Windows x64)
    sub rsp, 40

    ; 1) Mostrar prompt: "Ingrese un numero:"
    mov rcx, -11              ; STD_OUTPUT_HANDLE
    call GetStdHandle
    mov r12, rax              ; guarda handle para salida

    mov rcx, r12
    lea rdx, [mensaje_entrada]
    mov r8d, mensaje_entrada_len
    lea r9, [num_leidos]
    xor rax, rax
    call WriteConsoleA

    ; 2) Leer entrada (hasta 64 bytes)
    mov rcx, -10              ; STD_INPUT_HANDLE
    call GetStdHandle
    mov rcx, rax
    lea rdx, [buffer]
    mov r8d, 64
    lea r9, [num_leidos]
    xor rax, rax
    call ReadConsoleA

    ; 3) Convertir ASCII -> entero (64-bit)
    xor rax, rax              ; resultado acumulado
    lea rsi, [buffer]
convert_loop:
    mov al, [rsi]
    cmp al, 13                ; ENTER (CR)
    je convert_done
    cmp al, '0'
    jb convert_done
    cmp al, '9'
    ja convert_done

    ; resultado = resultado * 10 + (al - '0')
    mov rdx, rax
    shl rax, 1
    lea rax, [rax + rdx*4]    ; rax*5 + rax == rax*10
    movzx rdx, al
    sub rdx, '0'
    add rax, rdx
    inc rsi
    jmp convert_loop

convert_done:
    mov [numero], rax

    ; 4) Convertir entero -> ASCII usando DIV y revirtiendo
    mov rax, [numero]
    cmp rax, 0
    jne convert_num_to_ascii

    ; Caso especial 0
    mov byte [finalbuf], '0'
    mov byte [finalbuf+1], 13
    mov byte [finalbuf+2], 10
    mov dword [final_len], 3
    jmp print_converted

convert_num_to_ascii:
    xor rcx, rcx              ; contador de dígitos almacenados
    mov rbx, 10

convert_num_loop:
    xor rdx, rdx              ; limpiar RDX antes de DIV (requisito x64)
    div rbx                   ; RAX = RAX / 10, RDX = RAX % 10
    add dl, '0'
    mov [outbuf + rcx], dl
    inc rcx
    cmp rax, 0
    jne convert_num_loop

    ; invertimos los dígitos desde outbuf -> finalbuf
    xor rsi, rsi              ; índice de salida final
reverse_digits:
    dec rcx
    mov al, [outbuf + rcx]
    mov [finalbuf + rsi], al
    inc rsi
    cmp rcx, 0
    jne reverse_digits

    ; Agregar CR LF
    mov byte [finalbuf + rsi], 13
    inc rsi
    mov byte [finalbuf + rsi], 10
    inc rsi
    mov [final_len], esi

print_converted:
    ; 5) Mostrar mensaje "Numero convertido:"
    mov rcx, r12
    lea rdx, [mensaje_convertido]
    mov r8d, mensaje_convertido_len
    lea r9, [num_leidos]
    xor rax, rax
    call WriteConsoleA

    ; 6) Mostrar texto convertido
    mov rcx, r12
    lea rdx, [finalbuf]
    mov r8d, [final_len]
    lea r9, [num_leidos]
    xor rax, rax
    call WriteConsoleA

    ; 7) Salir exitosamente
    xor ecx, ecx
    call ExitProcess
