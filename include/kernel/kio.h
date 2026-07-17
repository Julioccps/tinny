#ifndef KIO_H
#define KIO_H

#include <stdarg.h>

void vformat(void (*sink)(char, void*), void *ctx, const char *fmt, va_list ap);

void kprintf(const char *fmt, ...);

#endif
