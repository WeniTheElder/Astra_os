[BITS 32]

global _start           ; Makes the label visible to the linker
extern kernel_start

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

    call kernel_start
    
    jmp $               ; Infinite jump so it doesn't try to execute uninitialized memeory
;
times 512 - ($-$$) db 0