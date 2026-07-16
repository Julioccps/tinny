# LibC

First thing you may ask: 'Why?'; to which I answer sincerely, I am not sure, but
I'll do it anyway. Now to how will I do it.
We'll have 2 major components, let's talk about them one by one.

## First Component: Assembly Backend

- Each function will be tied into a syscall or multiple ones in a specific order
the Assembly backend will be exactly that, that bare-bones implementation of
each and every basic function;
- Those basic functions will be defined inside [tinasm.h](../include/libc/tinasm.h) 
and will be used in most if not all **tin** adjecent header files inside the libc 
implementation.

- Like in other operating systems, it's valid to mention that the kernel's 
syscall implementation is different from the Assembly backend of the libc:
user programs cannot reach BIOS services or privileged instructions — by the
time they run, the CPU is in protected mode ring 3 with no path back. The
only way into the kernel is `int 0x80`, and the boundary is enforced by the
hardware privilege model, not by convention; [see also](arch.md).

## Second Component: Actual C implementation

- As stated in the previous component, there will be an actual implementation of
each function the developer may need using the Assembly backend, but how that 
should, and will work: using the header ([tinasm.h](../include/libc/tinasm.h))
as a wrapper to the Assembly backend, the functions will be developed in C
for maintainability reasons.

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
The LibC is organized into "tin" headers that provide a Unix-like API:
- `tinasm.h`: The direct bridge to syscalls.
- `tinio.h`: Buffered I/O, `printf`, `scanf`.
- `tinstr.h`: String manipulation (`strlen`, `strcpy`).
- `tinmem.h`: Memory management (`malloc`, `free`).
- `tindef.h`: Common definitions and macros.
