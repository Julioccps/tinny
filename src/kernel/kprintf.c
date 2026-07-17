#include <kernel/kio.h>
#include <kernel/vga.h>

static const char *NULL_STRING = "(null)";

static void kputc(char c, void *ctx) { vga_putchar(c); }
static void kputs(const char *s){
    while (*s) vga_putchar(*s++);
    vga_putchar('\n');
}
static void emit_str(void (*sink)(char, void *), void *ctx, char *s){
    if (!s) {
        while (*NULL_STRING) sink(*NULL_STRING++, ctx);
    } else{
        while (*s) sink(*s++, ctx);
    }

}
static void emit_int(void (*sink)(char, void *), void *ctx, unsigned v){
    char buf[12];
    char *p = buf + sizeof buf;
    do {
        int d = v % 10;
        *--p = '0' + d;
        v /= 10;
    } while (v);
    while (p < buf + sizeof buf) sink(*p++, ctx);
}
static void emit_uint(void (*sink)(char, void *), void *ctx, unsigned v, unsigned base){
    char buf[11];
    char *p = buf + sizeof buf;
    do {
        int d = v % base;
        *--p = d < 10? '0'+d: 'a'+d-10;
        v /= base;
    } while (v);
    while (p < buf + sizeof buf) sink(*p++, ctx);
}
void vformat(void (*sink)(char, void *), void *ctx, const char *fmt, va_list ap){
    for (; *fmt; fmt++){
        if (*fmt != '%') { sink(*fmt, ctx); continue;}
        fmt++;
        switch (*fmt){
            case 'c': sink((char)va_arg(ap, int), ctx); break;
            case 's': emit_str(sink, ctx, va_arg(ap, const char*)); break;
            case 'd': emit_int (sink, ctx, va_arg(ap, int)); break;
            case 'u': emit_uint(sink, ctx, va_arg(ap, unsigned), 10); break;
            case 'x': emit_uint(sink, ctx, va_arg(ap, unsigned), 16); break;
            case 'p': /* "0x" + emit_uint(..., 16) of a uintptr_t */ break;
            case '%': sink('%', ctx); break;         // literal %%
            case '\0': sink('%', ctx); return;       // % at end of string — stop
            default:  sink('%', ctx); sink(*fmt, ctx); break;  // unknown, echo it
        }
    }
}

void kprintf(const char *fmt, ...){
    va_list ap;
    va_start(ap, fmt);
    vformat(kputc, 0, fmt, ap);
    va_end(ap);
}
