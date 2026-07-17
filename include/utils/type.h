#ifndef TYPE_H
#define TYPE_H

/* POSIX types not covered by <stdint.h> (fixed widths) or <stddef.h> (size_t).
 * Placeholder until a real <sys/types.h> exists. */

typedef int  pid_t;
typedef long off_t;
typedef long ssize_t;

#endif
