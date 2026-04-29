BITS 16                 ; Switch to 16-bit code to be able to work in real mode

jmp 0x7c0:start         ; Set cs to 0x7c0 and ip to start (0)

start:
    cli                 ; Clear interrupts
    mov ax, 0x7c0
    mov ds, ax          ; Update the data segment register to 0x7c0
    mov es, ax          ; Update the extra segment register to 0x7c0
    mov ax, 0x00        
    mov ss, ax          ; Update the stack segment register to 0x00
    mov sp, 0x7c00      ; Update the stack pointer to 0x7c00
    sti                 ; Enable interrupts

    mov si, message     
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

times 446 - ($-$$) db 0 ; Fill the rest of the sector with zeros until byte 446

; Partition Table Entry 1
db 0x80                 ; Boot indicator, 0x80 means active/bootable (0b10000000), 0x00 means inactive
db 0x00, 0x02, 0x00     ; Starting CHS (Dummy values), BIOS ignores it for type 0x0C
db 0x0C                 ; Partition type, 0x0C = FAT32 with LBA
db 0xFF, 0xFF, 0xFF     ; Ending CHS (Dummy values)
dd 2048                 ; Starting LBA. Modern partitions typically start at sector 2048
dd 125120120            ; Size in sectors: 125,120,120 sectors (60 GB) The size of our flash drive

; Partition Table Entries 2, 3, and 4 (Unused)
times 48 db 0           ; Fill the next 48 bytes with zeros (The last 3 entries)

dw 0xaa55               ; Place the signature at the last two bytes (510 & 511)
