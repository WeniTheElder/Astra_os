ORG 0x7c00
BITS 16                 ; Switch to 16-bit code to be able to work in real mode

CODE_SEG equ gdt_code - gdt_start
DATA_SET equ gdt_data - gdt_start

jmp 0:start             ; Set cs to 0x7c0 and ip to start label

start:
    cli                 ; Clear interrupts
    mov ax, 0x0         ; Move address 0x0 to the ax register
    mov ds, ax          ; Set the Data Segment Register to point to address 0x0
    mov es, ax          ; Set the extra segment to point to 0x0
    mov ss, ax          ; Set the stack segement to point to 0x0
    mov sp, 0x7c00      ; Set the Stack pointer to point at address 0x7c00
    sti                 ; Renable interrupts
.load_protected:
    cli
    lgdt[gdt_descriptor]
    mov eax, cr0
    or  eax, 0x1
    mov cr0, eax
    jmp CODE_SEG:load_32
;

gdt_start:

gdt_null:
    dd 0x0
    dd 0x0
;

; Offset 0x8
gdt_code:               ; CS should point to this
    dw 0xffff           ; Segment limit first 0-15 bits
    dw 0                ; Base first 0-15 bits
    db 0                ; Base 16-32 bits
    db 0x9a             ; Access byte
    db 0b11001111       ; Set flags
    db 0x0              ; base 24-31
;

; Offset 0x10
gdt_data:               ; DS, SS, ES, FS, GS
    dw 0xffff           ; Segment limit first 0-15 bits
    dw 0x0              ; Base first 0-15 bits
    db 0x0              ; Base 16-32 bits
    db 0x92             ; Access byte
    db 0b11001111       ; Set flags
    db 0x0              ; base 24-31
gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start-1
    dd gdt_start
;
[BITS 32]
load_32:
    mov ax, DATA_SET    ; Load data segment selector
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov esp, 0x7c00     ; Set up the stack pointer for protected mode
    jmp $               ; Infinite jump so it doesn't try to execute our data
;

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

dw 0xAA55               ; Place the signature at the last two bytes (510 & 511)