[ORG 0x7c00] 
[BITS 16]                 ; Switch to 16-bit code to be able to work in real mode

CODE_SEG equ gdt_code - gdt_start   ; 0x8
DATA_SEG equ gdt_data - gdt_start   ; 0x10

jmp 0:start             ; Set cs to 0x7c0 and ip to start label

start:
    cli                 ; Clear interrupts
    mov ax, 0x0         ; Move address 0x0 to the ax register
    mov ds, ax          ; Set the Data Segment Register to point to address 0x0
    mov es, ax          ; Set the extra segment to point to 0x0
    mov ss, ax          ; Set the stack segment to point to 0x0
    mov sp, 0x7c00      ; Set the Stack pointer to point at address 0x7c00
    sti                 ; Renable interrupts
.load_protected:
    cli                 ; Clear interrupts

    ; Enable A20 line
    in al, 0x92
    or al, 2
    out 0x92, al

    lgdt[gdt_descriptor]; Load GDT register with start address of Global Descriptor Table
    mov eax, cr0        ; Copy the Control Register0's value to eax
    or  al, 0x1         ; Set the first bit in the al
    mov cr0, eax        ; Set the Protection Enbale bit in CR0

    jmp CODE_SEG:load32 ; 
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


load32:
    mov eax, 1              ; Start sector
    mov edi, 0x0100000      ; Destination memory address (1MB)
    call ata_lba_read       ; Load the kernel into memory address 1MB and jump to it
    jmp CODE_SEG:0x0100000  
;

ata_lba_read:
mov ebx, eax          ; Backup LBA in ebx regiseter
; Read LBA bits and send them on the corresponding port number
shr eax, 24           ; Bits 24-27
or eax, 0xE0          ; Select master drive and LBA mode
mov dx, 0x1F6
out dx, al

mov eax, ebx          ; Bits 0-7
mov dx, 0x1F3
out dx, al

mov eax, ebx          ; Bits 8-15
shr eax, 8
mov dx, 0x1F4
out dx, al

mov eax, ebx          ; Bits 16-23
shr eax, 16
mov dx, 0x1F5
out dx, al


; Read all sectros into memory
.next_sector:
    push ecx        ; Store the sector counter in ecx

; Checking if we need to read
.try_again:
    mov dx, 0x1F7
    in al, dx
    test al, 8
    jz .try_again   ; Keep trying until 3rd bit is set, meaning controller is ready to send data
    
    ; Read 256 words (512 bytes = 1 sector) from data port 0x1F0
    mov ecx, 256   
    mov dx, 0x1F0
    rep insw
    pop ecx
    loop .next_sector
    ; End of reading sectors into memory
    ret

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