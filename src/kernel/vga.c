#include <kernel/vga.h>
#include <string.h>
#include <stdint.h>

volatile uint16_t *vga = (volatile uint16_t*)VGA_MADD;
static int row, col;

void vga_putchar(char c){
    if (c == '\n') {
        col = 0;
        row++;
    }
    else vga[row*80 + col++] = (uint16_t)c | (0x0F << 8);
    if (col >= 80) {
        col = 0;
        row++;
    }
}

void scroll(void){
    memmove((void *)vga, (void *)vga+80, 80*24*2);
}
