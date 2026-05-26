#ifndef TINASM_H
#define TINASM_H

/* Assembly backend functions */

#ifndef __ASSEMBLER__

#include "utils/type.h"

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
