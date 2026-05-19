section .asm

global idt_load
idt_load:
    push ebp
    mov ebp, esp

    mov ebx, [ebp+8] ; Copies the first argument passed to he ebx register
    lidt [ebx]
    
    pop ebp
    ret