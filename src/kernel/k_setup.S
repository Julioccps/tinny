#include "core/syscalls.h"
.globl _start

.text
_start:
    call idt_setup
    # installs exceptions 0-31 + syscall gate 0x80 (idt.S)
    # call fs_init ; future, Not now
    call kmain
    ret

.globl syscall_handler
syscall_handler:
    pushal
    cmpl $SYS_EXIT, %eax
    je sys_exit
    cmpl $SYS_FORK, %eax
    je sys_fork
    cmpl $SYS_READ, %eax
    je sys_read
    cmpl $SYS_WRITE, %eax
    je sys_write
    cmpl $SYS_OPEN, %eax
    je sys_open
    cmpl $SYS_CLOSE, %eax
    je sys_close
    cmpl $SYS_WAITPID, %eax
    je sys_waitpid
    cmpl $SYS_EXECVE, %eax
    je sys_execve
    cmpl $SYS_BRK, %eax
    je sys_brk
    cmpl $SYS_GETPID, %eax
    je sys_getpid
    cmpl $SYS_MMAP, %eax
    je sys_mmap
    cmpl $SYS_MUNMAP, %eax
    je sys_munmap
    cmpl $SYS_MPROTECT, %eax
    je sys_mprotect
    cmpl $SYS_SELECT, %eax
    je sys_select
    cmpl $SYS_POLL, %eax
    je sys_poll
    cmpl $SYS_IOCTL, %eax
    je sys_ioctl
    cmpl $SYS_STAT, %eax
    je sys_stat
    cmpl $SYS_LSEEK, %eax
    je sys_lseek
    cmpl $SYS_DUP, %eax
    je sys_dup
    cmpl $SYS_DUP2, %eax
    je sys_dup2
    cmpl $SYS_PIPE, %eax
    je sys_pipe
    cmpl $SYS_CHDIR, %eax
    je sys_chdir
    cmpl $SYS_GETCWD, %eax
    je sys_getcwd
    popal
    iretl
# TODO: Create the syscalls that don't need the file system yet.
