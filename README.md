# Cajero Automático en NASM x64

Este proyecto es un simulador de cajero automático implementado en ensamblador NASM para arquitectura x64 en Windows. El programa permite validar un PIN, consultar saldo, depositar y retirar dinero, con manejo básico de errores y validaciones.

## Características

- **Validación de PIN**: El usuario debe ingresar el PIN correcto (1234) en hasta 3 intentos antes de que la tarjeta se bloquee.
- **Menú principal**: Opciones para consultar saldo, depositar, retirar o salir.
- **Operaciones bancarias**:
  - Consultar saldo actual.
  - Depositar dinero (monto positivo).
  - Retirar dinero (si hay fondos suficientes).
- **Manejo de errores**: Mensajes para opciones inválidas, entradas no numéricas, fondos insuficientes, etc.
- **Interfaz de consola**: Entrada y salida a través de la consola de Windows.

## Requisitos

- **Sistema operativo**: Windows (x64).
- **Ensamblador**: NASM (Netwide Assembler).
- **Enlazador**: Compatible con Windows (ej. Microsoft Link o GoLink).
- **Bibliotecas**: Utiliza funciones de la API de Windows (kernel32.dll).

## Compilación

1. **Ensamblar el código**:
   ```
   nasm -f win64 main.asm -o build/main.obj
   ```

2. **Enlazar el objeto**:
   - Con Microsoft Link:
     ```
     link /subsystem:console /entry:main build/main.obj kernel32.lib /out:main.exe
     ```
   - Con GoLink:
     ```
     golink /console /entry main build/main.obj kernel32.dll
     ```

## Ejecución

Ejecuta el programa desde la línea de comandos:
```
main.exe
```

Sigue las instrucciones en pantalla:
- Ingresa el PIN: `1234`
- Selecciona una opción del menú (1-4).

## Estructura del Proyecto

- `main.asm`: Código fuente principal en NASM.
- `build/`: Directorio para archivos objeto (main.obj).
- `README.md`: Este archivo.

## Detalles Técnicos

- **Convención de llamadas**: Windows x64 (parámetros en rcx, rdx, r8, r9).
- **Funciones de la API**: GetStdHandle, WriteConsoleA, ReadConsoleA, ExitProcess.
- **Manejo de entrada/salida**: Conversión ASCII a entero y viceversa.
- **Estado global**: Saldo inicial de $1000, PIN fijo.

## Notas

- Este es un proyecto educativo para aprender ensamblador x64 en Windows.
- No incluye persistencia de datos; el saldo se reinicia en cada ejecución.
- Para mejoras, considera agregar más validaciones o persistencia.

## Licencia

Este proyecto es de código abierto. Úsalo bajo tu propio riesgo.