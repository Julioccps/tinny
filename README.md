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
    - [ ] Libc initial implementation (Just what's required for basic programs);
    - [ ] Basic Kernel;
    - [ ] Syscall handler;
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
    - [ ] Networking (unfortunately, it will have to be Wi-Fi, as the target computer does
                     not have an RJ-45 port).
    - [ ] Gaming (no more comments);
    - [ ] Updates on each and everything, made possible, just a connection to the repo
    and being able to clone it, and rebuild itself, to finally achieve:
- [ ] Final Goal - Self-Hosting.

## Project Structure
```bash
├── LICENSE
├── Makefile
├── README.md
├── docs
│   ├── arch.md
│   ├── ef.md
│   ├── fs.md
│   └── libc.md
├── include
│   ├── core
│   │   ├── syscalls.h
│   │   ├── tef.h
│   │   └── tfs.h
│   ├── libc
│   │   ├── tinasm.h
│   │   └── tinio.h
│   └── utils
│       └── type.h
├── src
│   ├── apps
│   │   └── shell
│   │       └── main.c
│   ├── boot
│   │   └── bootloader.asm
│   ├── kernel
│   │   └── kernel.c
│   ├── libc
│   │   └── tinasm.S
│   └── linker.ld
``` 

### Final Comments

I'll do my best to document everything and share insights inside comments or on
actual documentation.

To me, this project is kinda lame, if I'm being completely honest with myself,
but I still want to do it and have fun while at it.

##### Some quotes for ya'
> "Admiration comes from understanding."

> "Complexity is a engineer's problem, the end user shouldn't be the target of not even a bit of that, our true objective is to make the user's experience truly excellent and have nothing that would make any user do anything but play and enjoy it"
"
