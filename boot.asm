ORG 0x7c00              ;Place the origin of our address to 0x7c00
BITS 16                 ;Switch to 16-bit code to be able to work in real mode

start:
    mov si, message     
    call print
    jmp $               ;infinite loop

print:
    mov bx, 0           ;select page number
.loop:
    lodsb               
    cmp al, 0
    je .done            ;return if string is done
    call print_char     ;else -> print the char
    jmp .loop
.done:
    ret
print_char:
    mov ah, 0x0e        ;teletype output
    int 0x10            ;calls BOIS video functions
    ret


message db "Hello, world!", 0xa 

times 510 - ($-$$) db 0 ;Fill the rest of the sector with zeros until byte number 510
dw 0xaa55               ;Place the signature at the last two bytes (511 & 512)