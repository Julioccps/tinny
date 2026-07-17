#include <string.h>

void *memcpy(void *dest, const void *src, size_t n){
    char *d = dest;
    const char *s = src;
    for (; n; n--) *d++ = *s++;
    return d;
}
