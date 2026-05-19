#include "idt.h"
#include "../kernel.h"
#include "../config.h"
#include "../memory/memory.h"

struct idt_desc idt_descriptors[ASTRA_OS_TOTAL_INTERRUPTS];
struct idtr_desc idtr_descriptor;

extern void idt_load(struct idtr_desc* ptr);

void idt_zero(){ // Interrupt descriptor zero
    print("Divide by zero error");
}

void idt_set(int interrupt_no, void* address){
    struct idt_desc* desc = &idt_descriptors[interrupt_no];
    
    desc->offset_1 = (uint32_t) address & 0x0000ffff;
    desc->selector = KERNEL_CODE_SELECTOR;
    desc->zero = 0x00;
    desc->type_attr = 0xEE;
    desc->offset_2 = (uint32_t) address >> 16;
}

void init_idt(){
    // Initialize IDT with zeros
    memset(idt_descriptors, 0, sizeof(idt_descriptors));
    // Initialize IDTR 
    idtr_descriptor.limit = sizeof(idt_descriptors) - 1;
    idtr_descriptor.base = (uint32_t) idt_descriptors;

    // Set the interrupt descriptor zero
    idt_set(0, idt_zero);

    // Load interrupt descriptor table
    idt_load(&idtr_descriptor);
}