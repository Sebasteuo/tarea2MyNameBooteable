[BITS 16]
[ORG 0x7C00]

start:
    ; Inicializar segmentos
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    sti

    ; Limpiar la pantalla antes de imprimir
    call clear_screen

    ; Obtener una semilla basada en el tiempo que el usuario tarda en presionar una tecla
    call get_user_time_based_seed
    mov [random_seed], ax    ; Guardar la semilla en la variable random_seed

    ; Generar posiciones aleatorias iniciales
    call random_position

    ; Imprimir los nombres inicialmente
    call print_sebastian
    call print_karina

    ; Bucle infinito para manejar teclas
handle_input:
    call wait_for_keypress
    cmp al, 'r'              ; Tecla 'R' para reiniciar el juego (minúscula)
    je restart_game
    cmp al, 'R'              ; Tecla 'R' para reiniciar el juego (mayúscula)
    je restart_game
    cmp al, 'e'              ; Tecla 'E' para finalizar el juego (minúscula)
    je exit_game
    cmp al, 'E'              ; Tecla 'E' para finalizar el juego (mayúscula)
    je exit_game
    cmp ah, 0x4B             ; Flecha izquierda (Rotación 90 grados a la izquierda)
    je rotate_left
    cmp ah, 0x4D             ; Flecha derecha
    je handle_input          ; Placeholder para futura implementación de flecha derecha
    cmp ah, 0x48             ; Flecha arriba
    je handle_input          ; Placeholder para futura implementación de flecha arriba
    cmp ah, 0x50             ; Flecha abajo
    je handle_input          ; Placeholder para futura implementación de flecha abajo
    jmp handle_input

; Reiniciar el juego
restart_game:
    call clear_screen        ; Limpiar la pantalla
    call random_position     ; Generar nuevas posiciones aleatorias
    call print_sebastian     ; Imprimir "Sebastian" nuevamente
    call print_karina        ; Imprimir "Karina" nuevamente
    jmp handle_input         ; Volver al bucle principal

; Finalizar el juego
exit_game:
    call clear_screen        ; Limpiar pantalla antes de salir
    mov ah, 0x0E             ; Mostrar mensaje de salida
    mov al, 'G'              ; Mostrar "Goodbye"
    int 0x10
    mov al, 'o'
    int 0x10
    mov al, 'o'
    int 0x10
    mov al, 'd'
    int 0x10
    mov al, 'b'
    int 0x10
    mov al, 'y'
    int 0x10
    mov al, 'e'
    int 0x10
    mov ah, 0x00
    int 0x16                 ; Pausa para esperar tecla antes de salir
    jmp $

; Rotación a la izquierda (90 grados sobre el eje vertical)
rotate_left:
    call clear_screen
    call rotate_left_sebastian
    call rotate_left_karina
    jmp handle_input

; Subrutina para rotar "Sebastian" 90 grados a la izquierda
rotate_left_sebastian:
    mov ah, 0x02        ; Mover el cursor a la posición de inicio
    mov bh, 0           ; Página 0
    mov dh, [row_sebastian]    ; Fila pseudoaleatoria
    mov dl, [col_sebastian]    ; Columna pseudoaleatoria

    ; Rotar las letras 90 grados a la izquierda (mostrar en columna)
    ; Cada letra se imprime en una fila distinta
    mov ah, 0x0E
    mov al, 'S'
    int 0x10            ; Imprimir la letra 'S'
    inc dh              ; Mover a la siguiente fila
    mov ah, 0x02
    int 0x10            ; Mover cursor
    mov al, 'e'
    int 0x10            ; Imprimir la letra 'e'
    inc dh
    mov ah, 0x02
    int 0x10
    mov al, 'b'
    int 0x10
    inc dh
    mov ah, 0x02
    int 0x10
    mov al, 'a'
    int 0x10
    inc dh
    mov ah, 0x02
    int 0x10
    mov al, 's'
    int 0x10
    inc dh
    mov ah, 0x02
    int 0x10
    mov al, 't'
    int 0x10
    inc dh
    mov ah, 0x02
    int 0x10
    mov al, 'i'
    int 0x10
    inc dh
    mov ah, 0x02
    int 0x10
    mov al, 'a'
    int 0x10
    inc dh
    mov ah, 0x02
    int 0x10
    mov al, 'n'
    int 0x10
    ret

; Subrutina para rotar "Karina" 90 grados a la izquierda
rotate_left_karina:
    mov ah, 0x02        ; Mover el cursor a la posición de inicio
    mov bh, 0           ; Página 0
    mov dh, [row_karina]    ; Fila pseudoaleatoria
    mov dl, [col_karina]    ; Columna pseudoaleatoria

    ; Rotar las letras 90 grados a la izquierda (mostrar en columna)
    ; Cada letra se imprime en una fila distinta
    mov ah, 0x0E
    mov al, 'K'
    int 0x10            ; Imprimir la letra 'K'
    inc dh              ; Mover a la siguiente fila
    mov ah, 0x02
    int 0x10            ; Mover cursor
    mov al, 'a'
    int 0x10            ; Imprimir la letra 'a'
    inc dh
    mov ah, 0x02
    int 0x10
    mov al, 'r'
    int 0x10
    inc dh
    mov ah, 0x02
    int 0x10
    mov al, 'i'
    int 0x10
    inc dh
    mov ah, 0x02
    int 0x10
    mov al, 'n'
    int 0x10
    inc dh
    mov ah, 0x02
    int 0x10
    mov al, 'a'
    int 0x10
    ret

; Subrutina para obtener una semilla basada en el tiempo que el usuario tarda en presionar una tecla
get_user_time_based_seed:
    ; Obtener el valor actual del temporizador del BIOS antes de la tecla
    mov ah, 0x00
    int 0x1A                ; Obtener valor del temporizador
    push dx                 ; Guardar el valor del temporizador

    ; Esperar a que el usuario presione una tecla
    mov ah, 0x00
    int 0x16                ; Esperar una tecla

    ; Obtener el valor del temporizador después de la tecla
    mov ah, 0x00
    int 0x1A                ; Obtener valor del temporizador

    ; Restar los dos valores del temporizador para obtener la diferencia de tiempo
    pop ax                  ; Cargar el primer valor del temporizador
    sub dx, ax              ; Restar los tiempos para obtener una semilla variable
    mov ax, dx              ; Devolver la diferencia como la nueva semilla
    ret

; Subrutina para generar posiciones aleatorias cada vez que se reinicia
random_position:
    ; Generar posición pseudoaleatoria para "Sebastian"
    call random
    mov dl, al
    and dl, 0x0F           ; Limitarlo a 16 filas (0-15)
    mov [row_sebastian], dl
    call random
    mov dl, al
    and dl, 0x3F           ; Limitarlo a 64 columnas (0-63)
    mov [col_sebastian], dl

    ; Generar posición pseudoaleatoria para "Karina"
    call random
    mov dl, al
    and dl, 0x0F           ; Limitarlo a 16 filas (0-15)
    mov [row_karina], dl
    call random
    mov dl, al
    and dl, 0x3F           ; Limitarlo a 64 columnas (0-63)
    mov [col_karina], dl
    ret

; Subrutina para imprimir "Sebastian"
print_sebastian:
    mov ah, 0x02        ; Mover el cursor a la posición de "Sebastian"
    mov bh, 0           ; Página 0
    mov dh, [row_sebastian]
    mov dl, [col_sebastian]
    int 0x10

    mov ah, 0x0E        ; Imprimir el nombre "Sebastian"
    mov al, 'S'         ; Imprimir la letra 'S'
    int 0x10
    mov al, 'e'
    int 0x10
    mov al, 'b'
    int 0x10
    mov al, 'a'
    int 0x10
    mov al, 's'
    int 0x10
    mov al, 't'
    int 0x10
    mov al, 'i'
    int 0x10
    mov al, 'a'
    int 0x10
    mov al, 'n'
    int 0x10
    ret

; Subrutina para imprimir "Karina"
print_karina:
    mov ah, 0x02        ; Mover el cursor a la posición de "Karina"
    mov bh, 0           ; Página 0
    mov dh, [row_karina]
    mov dl, [col_karina]
    int 0x10

    mov ah, 0x0E        ; Imprimir el nombre "Karina"
    mov al, 'K'         ; Imprimir la letra 'K'
    int 0x10
    mov al, 'a'
    int 0x10
    mov al, 'r'
    int 0x10
    mov al, 'i'
    int 0x10
    mov al, 'n'
    int 0x10
    mov al, 'a'
    int 0x10
    ret

; Subrutina para generar números aleatorios
random:
    mov ax, [random_seed]
    inc ax
    mov dx, 0
    mov bx, 0x43FD         ; Constante multiplicativa
    mul bx
    add ax, 0xC39E         ; Incremento
    mov [random_seed], ax  ; Guardar nueva semilla
    mov al, ah             ; Devolver el byte superior como número aleatorio
    ret

; Subrutina para esperar la entrada del usuario
wait_for_keypress:
    mov ah, 0x00        ; Esperar a que se presione una tecla
    int 0x16            ; Leer la tecla presionada
    ret

; Subrutina para limpiar la pantalla
clear_screen:
    mov ax, 0x0600
    mov bh, 0x07        ; Color blanco sobre negro
    mov cx, 0           ; Esquina superior izquierda
    mov dx, 0x184F      ; Esquina inferior derecha
    int 0x10
    ret

; Variables de posición y semilla
random_seed dw 1234
row_sebastian db 12
col_sebastian db 10
row_karina db 13
col_karina db 10
