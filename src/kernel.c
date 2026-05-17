#include "kernel.h"

void kernel_main() {
    // Main kernel code here
    while(1) {
        // Infinite loop - kernel keeps running
    }
}

void kernel_start(){
    // Call the actual kernel main function
    kernel_main();
}