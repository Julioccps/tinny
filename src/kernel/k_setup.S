#include "core/syscalls.h"
.globl _start

.data
.align 8
idt_start:
/*  Explanation:
    We need 128 descriptors before our 0x80 syscall descriptor.
    Each descriptor is 8 bytes, 128 * 8 = 1024, we just 0 fill it.
*/
.fill 1024, 1, 0

idt_syscall_gate:
    .short  0       # [Bytes 0-1] Offset low (bits 0-15) - filled at runtime
    .short  0x0008  # [Bytes 2-3] Segment Selector (0x08 points to Bootloader's GDT Code)
    .byte   0       # [Byte 4] Reserved, always 0
    .byte   0xEF    # [Byte 5] Type & attribute (0xEF = Present, Ring 3 usable, 32-bit Interrupt Gate)
    .short  0       # [Bytes 6-7] Offset high (bits 16-31) - filled at runtime

.align 4
idt_descriptor:
    .short (129 * 8) - 1 # IDT Limit(Size of IDT - 1)
    .long idt_start

.text
_start:
    call syscall_setup
    # call fs_init ; future, Not now
    call kmain
    ret

syscall_setup:
    # Dynamically Split the 32-bit address of 'syscall_handler' into IDT Gate
    movl $syscall_handler, %eax
    # Store lower 16 bits of address into bytes 0-1 of the gate
    movw %ax, idt_syscall_gate
    # Shift right by 16 to get the upper 16 bits
    shrl $16, %eax
    # Store upper 16 bits into bytes 6-7 of the gate
    movw %ax, (idt_syscall_gate + 6)

    # For safety: Load the actual runtime address of idt_start
    movl $idt_start, %eax
    mov %eax, (idt_descriptor + 2)

    # load the IDT to the processor
    lidt idt_descriptor

    ret
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
