# Kernel Bring-up

What happens between the bootloader's final `jmp` and `kmain`, and the
contracts holding it together. Implemented in `src/kernel/k_setup.S`,
`src/kernel/gdt.S` and `src/kernel/idt.S`.

## Boot Handoff Contract

The bootloader (Stage 1, see [arch.md](arch.md)) hands over with:

- The kernel image copied to `0x00100000` (1MB), execution jumping to `_start`;
- CPU in 32-bit protected mode, interrupts disabled (`cli` since real mode);
- Segment registers loaded from the bootloader's flat GDT (code `0x08`, data `0x10`);
- No stack the kernel should trust — `_start` switches to its own immediately.

## Kernel Size Budget: 32 KB

Three magic numbers in three files define how much kernel gets loaded, and
they **must move together** when the kernel outgrows them:

| File | Value | Meaning |
| ---- | ----- | ------- |
| `src/boot/bootloader.asm` | `mov al, 0x40` | BIOS int 13h reads 64 sectors (32 KB) from disk |
| `src/boot/bootloader.asm` | `mov ecx, 0x2000` | copies 8192 dwords (32 KB) from staging to 1MB |
| `Makefile` | `truncate -s 33280` | image = 512B boot sector + 32 KB kernel |

> OBS.: If the kernel ever grows past 32 KB and the boot gets weird
> (half-loaded code, jumps into garbage), this table is why.

## Setup Order

`_start` does, in order:

1. `movl $kernel_stack_top, %esp` — switch to the dedicated 16 KB stack in `.bss`;
2. `call gdt_setup` — install the kernel GDT + TSS, `ltr`;
3. `call idt_setup` — install exception stubs, default gates and the syscall gate;
4. `call kmain` — C land. If it ever returns: `cli; hlt` forever.

## GDT / Selector Map

The bootloader GDT was scaffolding to reach protected mode; the kernel
installs its own and never looks back. Kernel code/data keep the same
selectors as the bootloader's table, so the swap is invisible to everything
already running (segment registers, IDT gate selectors).

| Selector | Entry | Notes |
| -------- | ----- | ----- |
| `0x00` | null | required by the CPU |
| `0x08` | kernel code, ring 0 | flat 4GB |
| `0x10` | kernel data, ring 0 | flat 4GB |
| `0x18` | user code, ring 3 | zeroed placeholder until user mode exists |
| `0x20` | user data, ring 3 | zeroed placeholder until user mode exists |
| `0x28` | TSS | base patched at runtime, then `ltr` |

## TSS

Used for exactly one thing: when an interrupt arrives while the CPU is in
ring 3, the CPU reads `SS0:ESP0` from the TSS to find the kernel stack.

- `SS0 = 0x10` (kernel data), `ESP0 = kernel_stack_top`;
- I/O map base = TSS size, meaning no I/O bitmap — ring 3 port access faults;
- Everything else in the 104-byte structure is hardware-task-switch legacy
  and stays zero. No hardware task switching is used, ever.

## IDT

One table for everything, 256 gates, no slot ever left "not present" — a
fault through a missing gate escalates straight to a triple fault (CPU
reset), which is exactly the failure mode the table exists to prevent.

| Vectors | Handler | Attribute |
| ------- | ------- | --------- |
| 0-31 | per-vector exception stubs -> `isr_common` (currently: clean halt) | `0x8E`, ring 0 |
| 32-255 | `isr_default` (clean halt) | `0x8E`, ring 0 |
| `0x80` (128) | `syscall_handler` | `0xEF`, ring 3 reachable |

Details worth remembering:

- Exceptions 8, 10-14, 17 and 21 push a CPU error code; the other vectors do
  not, so their stubs push a dummy `0` to keep the `isr_common` stack frame
  identical for every vector: `[vector][errcode][eip][cs][eflags]`.
- Gates are written at **runtime** because a handler's 32-bit address is
  split into two 16-bit halves inside the descriptor, and the linker can
  only relocate whole symbols, never a 16-bit slice of one. Same reason the
  TSS descriptor base (split into three fields) is patched at runtime.
