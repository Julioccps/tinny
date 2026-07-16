#ifndef UNISTD_H
#define UNISTD_H

/*  POSIX-ish system interface. Two layers live in this header:
    1. The standard names ported code expects (write, read, fork, ...),
       implemented in C on top of layer 2;
    2. The raw Assembly backend (sys_*, implemented in tinasm.S) — a TINNY
       extension, kept visible on purpose.
    Convention for both: the kernel returns negative error codes; the
    standard-name wrappers translate that to errno = -ret and return -1. */

#ifndef __ASSEMBLER__

#include <stddef.h> /* size_t (compiler-provided, freestanding-safe) */
#include "utils/type.h"

typedef isize_t ssize_t; /* until a proper sys/types.h exists */

/* --- Standard POSIX subset (v1) --- */

ssize_t read(int fd, void *buf, size_t count);
ssize_t write(int fd, const void *buf, size_t count);
int     close(int fd);
pid_t   fork(void);
int     execve(const char *filename, char *const argv[], char *const envp[]);
pid_t   getpid(void);
int     brk(void *addr);
int     dup(int oldfd);
int     dup2(int oldfd, int newfd);
int     pipe(int pipefd[2]);
int     chdir(const char *path);
char   *getcwd(char *buf, size_t size);
off_t   lseek(int fd, off_t offset, int whence);

/* lseek whence values */
#define SEEK_SET 0
#define SEEK_CUR 1
#define SEEK_END 2

/* --- TINNY extension: raw syscall backend (tinasm.S) --- */

void sys_exit(int exit_code);
int sys_fork(void); // TODO Look into if fork generates a return value
int sys_read(u32_t fd, char *buf, usize_t count);
int sys_write(u32_t fd, const char *buf, usize_t count);
int sys_open(const char* filename, int flags, int mode);
int sys_close(u32_t fd);
int sys_waitpid(pid_t pid, int* start_addr, int options);
int sys_execve(const char* filename, const char *const *argv, const char *const *envp);
int sys_brk(usize_t brk);
pid_t sys_getpid(void);
void *sys_mmap(void *addr, usize_t len, int prot, int flags, int fd, off_t offset);
int sys_munmap(void *addr, usize_t len);

#endif
#endif
