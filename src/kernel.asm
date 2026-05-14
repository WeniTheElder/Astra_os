[BITS 32]
global _start

CODE_SEG equ 0x08
DATA_SEG equ 0x10

_start:
    mov ax, DATA_SEG    ; Load data segment selector
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov ebp, 0x00200000 
    mov esp, ebp        ; Set up the stack pointer for protected mode

    jmp $               ; Infinite jump so it doesn't try to execute our data
;