#include "kernel.h"
#include <stdint.h>
#include <stddef.h>

// Global pointer to the VGA video memory
uint16_t* video_mem = NULL;

uint16_t terminal_make_char(char c, char color){
    return (color << 8) | c;
}

// Forward declaration
void terminal_put_char(int x, int y, char c, char color);

void init_terminal(void){
    video_mem = VGA_MEMORY;

    // Clear the terminal
    for(int y = 0; y < VGA_HEIGHT; ++y){
        for(int x = 0; x < VGA_WIDTH; ++x){
            terminal_put_char(x, y, ' ', 0);
        }
    }
}

// Returns the length of a c-style string
size_t strlen(const char* str){
    size_t length = 0;
    while(str[length]) length++;
    return length;
}

void terminal_write_char(char c, char color, size_t* col, size_t* row){
    if(c == '\n'){
        // Move the cursor to the beginning of the next line
        (*row)++;
        *col = 0;
        return;
    }
    terminal_put_char(*col, *row, c, color);
    (*col)++; // Move the cursor to the right one char
    if(*col >= VGA_WIDTH){ 
        // We reached the end of the line
        // Move the cursor to the beginning of the next line
        *col = 0;
        (*row)++;
        (*row) %= VGA_HEIGHT;
    }
}

void terminal_put_char(int x, int y, char c, char color){
    video_mem[(y * VGA_WIDTH) + x] = terminal_make_char(c, color);
}

void print(const char* str){
    static size_t col = 0;
    static size_t row = 0;
    size_t length = strlen(str);
    for(int i = 0; i < length; ++i){
        // Print each character of the str to the console
        terminal_write_char(str[i], WHITE, &col, &row);
    }
}

void kernel_main(void){
    init_terminal();

    print("Hello, world\n");
    print("Second line");
}