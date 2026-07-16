#ifndef ERRNO_H
#define ERRNO_H

/*  The glue that makes ported Unix code work: a failing call returns -1
    and leaves the error code here. The kernel returns negative codes from
    syscalls; libc wrappers do: if (ret < 0) { errno = -ret; return -1; }.
    Values follow classic Unix numbering — TINNY defines its own ABI, but
    there's no reason to be different where tradition is fine. */

extern int errno;

#define EPERM         1  /* Operation not permitted */
#define ENOENT        2  /* No such file or directory */
#define ESRCH         3  /* No such process */
#define EINTR         4  /* Interrupted system call */
#define EIO           5  /* I/O error */
#define EBADF         9  /* Bad file descriptor */
#define ECHILD       10  /* No child processes */
#define EAGAIN       11  /* Try again */
#define ENOMEM       12  /* Out of memory */
#define EACCES       13  /* Permission denied */
#define EFAULT       14  /* Bad address */
#define EBUSY        16  /* Device or resource busy */
#define EEXIST       17  /* File exists */
#define ENOTDIR      20  /* Not a directory */
#define EISDIR       21  /* Is a directory */
#define EINVAL       22  /* Invalid argument */
#define EMFILE       24  /* Too many open files */
#define ENOSPC       28  /* No space left on device */
#define EPIPE        32  /* Broken pipe */
#define ERANGE       34  /* Result out of range */
#define ENAMETOOLONG 36  /* Filename too long */
#define ENOSYS       38  /* Syscall not implemented */

#endif
