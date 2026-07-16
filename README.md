# TINNY - There Is No Name Yet
> that's a good name actually

## Proposition

What I'll try to make the OS be:

- Unix-like;
- From scratch (including libc);
- Modular;
- Predictable;
- Reliable? (Maybe not feasible).

## How?

C + Assembly + x86 (Yes, 32 bits).
As for why on each one:
- C: I want to get better at programming in C;
- Assembly: It's a bit of a requirement for OS dev;
- x86 and why 32 bits: The only real target is an old computer that I have, it
has support for 64 bits, but it only had 4GB anyway, I wouldn't lose anything.

## Why?

As I said in the previous section, I want to get better at programming in C, but
more than that, I am reading a lot of books and studying a lot of code related
to system programming, so it's a great way of testing it.

## Roadmap

- [x] Phase 0 - Pre-Implementation:
    - [x] Executable format definition;
    - [x] Basic tooling;
    - [x] Syscall definition;
    - [x] File System architecture (it's more about choosing how and what I'll
                                   actually do);
- [ ] Phase 1 - Initial Implementation:
    - [x] Bootloader;
    - [x] Kernel bring-up (IDT, GDT, TSS — see docs/kernel.md);
    - [ ] Libc initial implementation (Just what's required for basic programs);
    - [ ] Basic Kernel;
    - [ ] Syscall handler;
    - [ ] Memory management (physical allocator + paging — fork/mmap/brk
                            depend on it, so it comes before them);
    - [ ] File System;
    - [ ] First program, a shell;
- [ ] Phase 2 - Filling the House:
    - [ ] More robust libc;
    - [ ] Stable kernel;
    - [ ] Actual shell programs;
    - [ ] Start working with rendering other than VGA text rendering (x86
                                                                        offers
                                                                        that,
                                                                        but we
                                                                        should
                                                                        have the
                                                                        one for
                                                                        actual
                                                                        pixels
                                                                        on the
                                                                        screen);
   - [ ] A C compiler;
   - [ ] A Make clone, just the graph of recipes and dependencies;
   - [ ] A text editor;
> In that order.
- [ ] Phase 3 - "The Feast":
    - [ ] Networking (the target computer has no RJ-45 port, so either way a
                     USB stack comes first; USB-Ethernet vs Wi-Fi gets decided
                     when I'm actually there. The TCP/IP stack itself can be
                     developed earlier in QEMU against an emulated NIC).
    - [ ] Gaming (no more comments);
    - [ ] Updates on each and everything, made possible, just a connection to the repo
    and being able to clone it, and rebuild itself, to finally achieve:
- [ ] Final Goal - Self-Hosting.

## Project Structure

By purpose, not by file (files change too often to be listed here):

| Path | What lives there |
| ---- | ---------------- |
| `src/boot/` | Stage 1 bootloader (NASM, the 512-byte MBR) |
| `src/kernel/` | The kernel: entry point, GDT/TSS, IDT, C kernel |
| `src/libc/` | Libc: Assembly backend + C implementation |
| `src/apps/` | User programs (the shell starts here) |
| `src/linker.ld` | Kernel linker script (links at 1MB) |
| `include/core/` | Kernel-facing specs: syscalls, TEF, TFS headers |
| `include/libc/` | Libc headers (the `tin*` family) |
| `include/utils/` | Shared type definitions |
| `docs/` | Design docs, one per subsystem |

### Final Comments

I'll do my best to document everything and share insights inside comments or on
actual documentation.

To me, this project is kinda lame, if I'm being completely honest with myself,
but I still want to do it and have fun while at it.

##### Some quotes for ya'
> "Admiration comes from understanding."

> "Complexity is an engineer's problem, the end user shouldn't be the target of not even a bit of that, our true objective is to make the user's experience truly excellent and have nothing that would make any user do anything but play and enjoy it"
