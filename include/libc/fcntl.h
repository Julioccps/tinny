#ifndef FCNTL_H
#define FCNTL_H

/*  open() lives here per POSIX, not in unistd.h. Flag values follow the
    classic Unix octal convention. */

#define O_RDONLY  00
#define O_WRONLY  01
#define O_RDWR    02
#define O_CREAT   0100
#define O_TRUNC   01000
#define O_APPEND  02000

int open(const char *pathname, int flags, ...);

#endif
