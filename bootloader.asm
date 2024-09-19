[BITS 16]
[ORG 0x7C00]

start:
    cli                 ; Deshabilitar interrupciones
    xor ax, ax
    mov ds, ax          ; Configurar segmento de datos
    mov es, ax          ; Configurar segmento extra

    ; Mostrar mensaje de bienvenida
    mov si, welcome_msg
    call print_string
    call print_newline

    ; Esperar a que el usuario presione una tecla
    mov ah, 0x00
    int 0x16            ; Leer teclado (espera hasta que se presione una tecla)

    ; Mostrar mensaje antes de cargar la aplicación
    mov si, loading_app_msg
    call print_string
    call print_newline

    ; Configurar la dirección de carga para la aplicación
    mov bx, 0x8000      ; Offset de carga: 0x8000
    mov es, bx          ; Establecer segmento extra a 0x8000
    mov bx, 0           ; Offset dentro del segmento

    ; Intentar leer la aplicación desde el segundo sector
    mov ah, 0x02        ; Función BIOS: Leer sectores
    mov al, 2           ; Número de sectores a leer (2 sector), porque el juego es de mas de 512 bytes
    mov ch, 0           ; Cilindro 0
    mov cl, 2           ; Sector 2
    mov dh, 0           ; Cabeza 0
    int 0x13            ; Llamada BIOS para leer sectores
    jc disk_error       ; Si hay error, saltar a disk_error

    ; Mostrar mensaje si la lectura del disco fue exitosa
    mov si, after_disk_msg
    call print_string
    call print_newline

    ; Mensaje de depuración antes de saltar a la aplicación
    mov si, before_jump_msg
    call print_string
    call print_newline

    ; Saltar a la aplicación cargada en 0x8000:0x0000
    jmp 0x8000:0x0000   ; Saltar a la dirección de la aplicación

disk_error:
    ; Mostrar mensaje de error
    mov si, error_msg
    call print_string
    hlt

; Función para imprimir cadena
print_string:
    mov ah, 0x0E        ; Función BIOS: Imprimir carácter en modo TTY
.next_char:
    lodsb               ; Cargar siguiente carácter en AL
    cmp al, 0
    je .done            ; Si es 0 (fin de cadena), salir
    int 0x10            ; Llamada a BIOS para imprimir el carácter
    jmp .next_char
.done:
    ret

; Función para imprimir un salto de línea (retorno de carro y nueva línea)
print_newline:
    mov al, 0x0D        ; Retorno de carro (código ASCII)
    int 0x10
    mov al, 0x0A        ; Nueva línea (código ASCII)
    int 0x10
    ret

; Mensajes
welcome_msg:
    db "Bienvenido al juego, presione cualquier tecla para iniciar...", 0
loading_app_msg:
    db "Cargando aplicacion...", 0
after_disk_msg:
    db "Lectura del disco exitosa", 0
before_jump_msg:
    db "Antes de saltar a la aplicacion", 0
error_msg:
    db "Error al leer el disco", 0

; Firma de arranque
times 510 - ($ - $$) db 0
dw 0xAA55
