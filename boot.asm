BITS 16                 ; Switch to 16-bit code to be able to work in real mode

jmp 0x7c0:start         ; Set cs to 0x7c0 and ip to start label

handle_zero:
    ; Interrupt handler for interrupt zero
    ; Prints character 'A'
    mov ah, 0x0e
    mov al, 'A'
    mov bx, 0x00
    int 0x10
    iret

start:
    cli                 ; Clear interrupts
    ; Update registers
    mov ax, 0x7c0
    mov ds, ax          ; Set the data segment register to 0x7c0
    mov ax, 0x0040      ; Segment base for address 1024 (1024 / 16 = 0x0040) 
    mov ss, ax          ; Set the stack segment register to 0x0040 to be after the IVT
    mov sp, 0x7800      ; Set the stack pointer so absolute address is 0x7c00 (0x0400 + 0x7800)

    sti                 ; Renable interrupts

    mov ax, 0x0000      ; Set Extra Segment to 0 to access the IVT
    mov es, ax
    mov word[es:0x00], handle_zero ; Add the offset address of handle_zero to address 0x00
    mov word[es:0x02], ds          ; Add the segment address to the next 2 bytes

    int 0


    mov si, message     
    call print

    jmp $               ; Infinite loop so it doesn't try to execute our data

print:
    mov bx, 0           ; Select page number
.loop:
    lodsb               ; Moves char from [ds:si] to al and increments si to point to the next char
    cmp al, 0
    je .done            ; Return if string is done (char == 0)
    call print_char     ; Else -> print the char
    jmp .loop
.done:
    ret
print_char:
    mov ah, 0x0e        ; Teletype output
    int 0x10            ; Calls BOIS video functions
    ret


message db "I didn't crash!!", 0

times 446 - ($-$$) db 0 ; Fill the rest of the sector with zeros until byte 446

; Partition Table Entry 1
db 0x80                 ; Boot indicator, 0x80 means active/bootable (0b10000000), 0x00 means inactive/invalid
times 3 db 0            ; Starting CHS (Dummy values), BIOS ignores it for type 0x0C
db 0x0C                 ; Partition type, 0x0C = FAT32 with LBA
times 3 db 0            ; Ending CHS (Dummy values)
dd 2048                 ; Starting LBA. Modern partitions typically start at sector 2048. You can totally make 1 (Start from the second sector)
dd 120120120            ; Size in sectors: 125,120,120 sectors (60 GB) The size of our flash drive

; Partition Table Entries 2, 3, and 4 (Unused)
times 48 db 0           ; Fill the next 48 bytes with zeros (The last 3 entries)

dw 0xaa55               ; Place the signature at the last two bytes (510 & 511)
