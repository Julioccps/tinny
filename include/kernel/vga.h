#ifndef VGA_H
#define VGA_H

#define VGA_MADD 0xB8000 // VGA Memory Address

void vga_putchar(char c);
void scroll(void);

#endif
