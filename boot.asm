ORG 0                   ; Place the origin of our address to 0x7c00
BITS 16                 ; Switch to 16-bit code to be able to work in real mode

jmp 0x7c0:start         ; Set cs to 0x7c0 and ip to start (0)

start:
    cli                 ; Clear interrupts
    mov ax, 0x7c0
    mov ds, ax
    mov es, ax
    mov ax, 0x00
    mov ss, ax
    mov sp, 0x7c00
    sti                 ; Enables interrupts

    mov si, message     ;
    call print

    jmp $               ; Infinite loop so it doesn't try to execute our data

print:
    mov bx, 0           ; Select page number
.loop:
    lodsb               
    cmp al, 0
    je .done            ; Return if string is done
    call print_char     ; Else -> print the char
    jmp .loop
.done:
    ret
print_char:
    mov ah, 0x0e        ; Teletype output
    int 0x10            ; Calls BOIS video functions
    ret


message db "Hello, world!", 0

times 510 - ($-$$) db 0 ;Fill the rest of the sector with zeros until byte number 510
dw 0xaa55               ;Place the signature at the last two bytes (511 & 512)