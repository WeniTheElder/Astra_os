#ifndef IDT_H_
#define IDT_H_
#include <stdint.h>

struct idt_desc{
    uint16_t offset_1;  // Offset bits 0..15
    uint16_t selector;  // A code segment selector in GDT
    uint8_t zero;       // Unused, set to 0
    uint8_t type_attr;  // Type and attribute
    uint16_t offset_2;  // Offset bits 16..31
}__attribute__((packed));

struct idtr_desc{       // IDT Register
    uint16_t limit;     // Length of IDT - 1 
    uint32_t base;      // Address of the IDT
}__attribute__((packed));


void idt_zero();
void idt_set(int interrupt_number, void* address);
void init_idt();

#endif