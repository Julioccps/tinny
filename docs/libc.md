# LibC

First thing you may ask: 'Why?'; to which I answer sincerely, I am not sure, but
I'll do it anyway. Now to how will I do it.
We'll have 2 major components, let's talk about them one by one.

## First Component: Assembly Backend

- Each function will be tied into a syscall or multiple ones in a specific order
the Assembly backend will be exactly that, that bare-bones implementation of
each and every basic function;
- Those basic functions (the `sys_*` family, implemented in `tinasm.S`) are
declared inside [unistd.h](../include/libc/unistd.h) as a TINNY extension,
and are what every standard function is built on top of.

- Like in other operating systems, it's valid to mention that the kernel's 
syscall implementation is different from the Assembly backend of the libc:
user programs cannot reach BIOS services or privileged instructions — by the
time they run, the CPU is in protected mode ring 3 with no path back. The
only way into the kernel is `int 0x80`, and the boundary is enforced by the
hardware privilege model, not by convention; [see also](arch.md).

## Second Component: Actual C implementation

- As stated in the previous component, there will be an actual implementation of
each function the developer may need using the Assembly backend: the standard
functions are developed in C on top of the `sys_*` wrappers, for
maintainability reasons.
- **Error convention** (the glue that makes ported code work): the kernel
returns negative error codes; the C wrappers translate with
`if (ret < 0) { errno = -ret; return -1; }`. Error values live in
[errno.h](../include/libc/errno.h).

## \_start Contract

When the kernel transfers to an user program, it jumps directly to the \_start
the entry point is defined by the libc, not `main`, the esp (the top of the 
stack) points to `argc`, which is the integer representation of the number of 
command-line arguments, the `argv` right above that, in memory, which is an array 
of null-terminated strings, and above that sits `envp`, the environment,
structured the same way `argv` is; an array of `KEY=VALUE` null-terminated
string pointers.
`_start` reads these from the stack, then calls `main(argc, argv, envp)` when
`main` returns, the return value is set to `exit`, which calls `SYS_EXIT`. A
user program should never return from \_start; if somehow does, the kernel
should kill the process with a segmentation fault.

## Calling Conventions
TINNY follows the standard x86 32-bit conventions to ensure compatibility between C and Assembly.

### C Functions (`cdecl`)
All C functions in the LibC and user programs follow the `cdecl` convention:
- **Arguments:** Passed on the stack in reverse order (right-to-left).
- **Return Value:** Placed in the `eax` register.
- **Stack Cleanup:** The **caller** is responsible for cleaning the stack after the function returns.
- **Registers:**
- **Callee-saved:** `ebx`, `esi`, `edi`, `ebp` (must be preserved by the function).
- **Caller-saved:** `eax`, `ecx`, `edx` (may be modified by the function).
 
### System Calls
Syscalls use a register-based convention for speed:
- `eax`: Syscall Number.
- `ebx`, `ecx`, `edx`, `esi`, `edi`: Arguments 1 through 5.
- `eax`: Return value (negative values often indicate error codes).
      
## Standard Headers

The public headers use the **standard names** — that's the whole portability
play: existing software `#include <stdio.h>`, so if TINNY's libc answers to
the same names with the same signatures, porting becomes "compile it" instead
of "rewrite it". The rule: any function a header declares must behave exactly
like the standard says, or not exist at all — missing is honest (link error),
different is a lie.

- `unistd.h`: POSIX layer (`write`, `read`, `fork`, ...) + the `sys_*` raw
  backend as a TINNY extension.
- `stdio.h`: I/O — v1 is `putchar`/`puts`/`printf`; `FILE` and friends
  arrive with the filesystem.
- `string.h`: `strlen`, `strcpy`, ... and the `mem*` family (the standard
  puts them here, not in a memory header).
- `stdlib.h`: `malloc`/`free`, `exit`, `abort`, conversions.
- `errno.h`: error codes + the errno convention.
- `fcntl.h`: `open` and its `O_*` flags (POSIX puts it here, not unistd).

Provided by the compiler (freestanding), not by us: `stddef.h`, `stdint.h`,
`stdarg.h` — until self-hosting forces our own compiler to supply them.

The **tin** identity lives on in the implementation: `tinasm.S` is the
Assembly backend, and internal helpers get the `tin_` prefix. Boring outside,
TINNY inside.
