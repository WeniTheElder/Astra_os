ENTRY(_start)
OUTPUT_FORMAT(binary)

SECTIONS {
    /* Set the location counter to 1MB. 
       The kernel will be loaded here in RAM. */
    . = 1M;

    /* The .text section contains the executable code */
    .text : ALIGN(4K) {
        *(.text)
    }
    .rodata : ALIGN(4K) {
        *(.rodata)
    }
    .data : ALIGN(4K) {
        *(.data)
    }
    /* .bss is for uninitialized data. 
       This section doesn't take up space on the disk. */
    .bss : ALIGN(4K) {
        __bss_start = .;  /* Mark the start address of BSS */
        *(COMMON)
        *(.bss)
        __bss_end = .;    /* Mark the end address of BSS */
    }
}
/*  ALIGN(4K) ensures the section starts at a memory
    address divisible by 4096 bytes (a "page"). */
