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

- Like in other operating systems, it's it's valid to mention that the kernel's 
syscall implementation is different from the Assembly backend of the libc, as 
the libc should not need to use x86 Real Mode, by the fact that by the time user 
programs start to run, The CPU is in protected mode ring 3 with no path back. 
worth noting though, the security boundary is enforced by the hardware privilege
model, not by convention; [see also](arch.md).

## Second Component: Actual C implementation

- As stated in the previous component, there will be an actual implementation of
each function the developer may need using the Assmebly backend, but how that 
should, and will work: using the header ([tinasm.h](../include/libc/tinasm.h))
as a wrapper to the the Assembly backend, the functions will be developed in C
for maintainment reasons.

## \_start Contract

When the kernel transfers to an user program, it jumps directly to the \_start
the entry point is defined by the libc, not `main`, the esp (the top of the 
stack) points to `argc`, which is the integer representation of the number of 
command-line arguments, the `argv` right above that, in memory, which is an array 
of null-terminated strings, and above that sitis `envp`, the environment,
structured the same way `argv` is; an array of `KEY=VALUE` null-terminated
string pointers.
`_start` reads these from the stack, then calls `main(argc, argv, envp)` when
`main` returns, the return value is set to `exit`, which calls `SYS_EXIT`. A
user program should never return from \_start; if somehow does, the kernel
should kill the process with a segmentation fault.

## Calling Conventions

> TODO
