#ifndef SYSCALLS_H
#define SYSCALLS_H

/* Syscall numbers */

#define SYS_EXIT			0
#define SYS_FORK			1
#define SYS_READ			2
#define SYS_WRITE			3
#define SYS_OPEN			4
#define SYS_CLOSE			5
#define SYS_WAITPID		    6
#define SYS_EXECVE		    7
#define SYS_BRK				8
#define	SYS_GETPID		    9
#define SYS_MMAP			10
#define SYS_MUNMAP		    11
#define SYS_MPROTECT    	12
#define SYS_SELECT          13
#define SYS_POLL            14
#define SYS_IOCTL           15
#define SYS_STAT			16
#define SYS_LSEEK			17
#define SYS_DUP				18
#define SYS_DUP2			19
#define SYS_PIPE			20
#define SYS_CHDIR			21
#define SYS_GETCWD		    22
#endif
