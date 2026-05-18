#ifndef KERNEL_H_
#define KERNEL_H_
#include <stdint.h>
#include <stddef.h>

#define VGA_WIDTH 80
#define VGA_HEIGHT 20
#define VGA_MEMORY (uint16_t*)(0xB8000)

enum color{
    BLACK,
    BLUE,
    GREEN,
    CYAN, 
    RED,
    MAGENTA,
    BROWN,
    LIGHT_GREY,
    DARK_GREY,
    LIGHT_BLUE,
    LIGHT_GREEN,
    LIGHT_CYAN,
    LIGHT_RED,
    LIGHT_MAGNETA,
    YELLOW,
    WHITE,
};



uint16_t terminal_make_char(char c, char color);
size_t strlen              (const char* str);
void terminal_put_char     (int x, int y, char c, char color, uint16_t* video_mem);
void terminal_write_char   (char c, char color, size_t* col, size_t* row, uint16_t* video_mem);
void print                 (const char* str, uint16_t* video_mem);
void init_terminal         (uint16_t** video_mem);
void kernel_main           ();

#endif