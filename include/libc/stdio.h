#ifndef STDIO_H
#define STDIO_H

/*  v1 subset: character/line output and a small printf. No FILE, no
    buffering yet — those arrive with the filesystem. Any function declared
    here must behave exactly like the C standard says, or not exist at all:
    ported code trusts these names. */

#include <stddef.h>

#define EOF (-1)

int putchar(int c);
int getchar(void);
int puts(const char *s);
int printf(const char *format, ...);

/* Planned for v2 (needs the FS): FILE, fopen, fclose, fread, fwrite,
   fprintf, fgets, fflush, ... */

#endif
