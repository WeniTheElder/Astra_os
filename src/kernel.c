#include "kernel.h"
#include <stdint.h>
#include <stddef.h>

uint16_t terminal_make_char(char c, char color){
    return (color << 8) | c;
}

void init_terminal(uint16_t** video_mem){
    *video_mem = VGA_MEMORY;

    // Clear the terminal
    for(int y = 0;y<VGA_HEIGHT;++y){
        for(int x = 0;x<VGA_WIDTH;++x){
            terminal_put_char(x,y,' ',0,*video_mem);
        }
    }
}

// Returns the lenght of a c-style string
size_t strlen(const char* str){
    size_t length = 0;
    while(str[length]) length++;
    return length;
}

void terminal_write_char(char c, char color, size_t* col, size_t* row, uint16_t* video_mem){
    if(c == '\n'){
        // Move the cursor to the begging of the next line
        (*row)++;
        *col = 0;
        return;
    }
    terminal_put_char(*col, *row, c, color, video_mem);
    (*col)++; // Move the cursor to the right one char
    if(*col >= VGA_WIDTH){ 
        // We reached the end of the line
        // Move the cursor to the begging of the next line
        *col = 0;
        (*row)++;
    }
}

void terminal_put_char(int x, int y, char c, char color, uint16_t* video_mem){
    video_mem[(y*VGA_WIDTH) + x] = terminal_make_char(c, color);
}

void print(const char* str, uint16_t* video_mem){
    static size_t col = 0;
    static size_t row = 0;
    size_t length = strlen(str);
    for(int i = 0;i<length;++i){
        // Print each character of the str to the console
        terminal_write_char(str[i], WHITE, &col, &row, video_mem);
    }
}

void kernel_main(){
    uint16_t* video_mem = NULL;

    init_terminal(&video_mem);

    print("Hello,world\n", video_mem);
    print("Second line", video_mem);
}