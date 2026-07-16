#ifndef STDLIB_H
#define STDLIB_H

/*  v1 subset: process control and memory allocation. exit() maps to
    SYS_EXIT through the backend; malloc and friends sit on top of brk
    once memory management exists kernel-side. */

#include <stddef.h>

#define EXIT_SUCCESS 0
#define EXIT_FAILURE 1

/* Process control */
void exit(int status) __attribute__((noreturn));
void abort(void) __attribute__((noreturn));

/* Memory allocation */
void *malloc(size_t size);
void *calloc(size_t nmemb, size_t size);
void *realloc(void *ptr, size_t size);
void  free(void *ptr);

/* Conversions / misc */
int atoi(const char *nptr);
int abs(int j);

#endif
