/*  gdt.S — the kernel's own GDT + TSS.

    The bootloader GDT was throwaway scaffolding to reach protected mode;
    from gdt_setup onward the kernel runs on this table instead. Kernel
    code/data keep selectors 0x08/0x10, so every selector already baked
    into the IDT gates and the segment registers stays valid across the swap.

      0x00  null        (required)
      0x08  kernel code ring 0
      0x10  kernel data ring 0
      0x18  user code   ring 3 (placeholder, zero = not present yet)
      0x20  user data   ring 3 (placeholder, zero = not present yet)
      0x28  TSS         base patched at runtime, then ltr

    The TSS exists for exactly one thing here: when an interrupt arrives
    from ring 3, the CPU loads SS0:ESP0 from it to find the kernel stack.
*/
.globl gdt_setup
.globl kernel_stack_top

.text
gdt_setup:
    # Patch the TSS base into its descriptor. The 32-bit address is split
    # across three separate fields, so the linker cannot fill it in
    # (same reason the IDT gates are written at runtime).
    movl  $tss_storage, %eax
    movw  %ax, tss_descriptor + 2       # base bits 0-15
    shrl  $16, %eax
    movb  %al, tss_descriptor + 4       # base bits 16-23
    movb  %ah, tss_descriptor + 7       # base bits 24-31

    lgdt  gdt_descriptor

    # Reload every data segment register from the new table
    movw  $0x10, %ax
    movw  %ax, %ds
    movw  %ax, %es
    movw  %ax, %fs
    movw  %ax, %gs
    movw  %ax, %ss

    # Far jump so CS is reloaded from the new table too
    ljmp  $0x08, $.Lflush_cs
.Lflush_cs:
    # Load the task register with the TSS selector
    movw  $0x28, %ax
    ltr   %ax
    ret

.data
gdt_start:
    .long 0x0               # Null descriptor (required, 8 bytes)
    .long 0x0
kernel_code:			    # Code Segment Descriptor (Offset 0x08)
	.short 0xFFFF			# Limit (low 16 bits)
	.short 0x0000			# Base (low 16 bits)
	.byte 0x00				# Base (next 8 bits)
	.byte 0b10011010	    # Access byte (Exec/Read, Ring 0)
	.byte 0b11001111	    # Granularity (4KB Blocks, 32-bits protected)
	.byte 0x00				# Base (high 8 bits)

kernel_data:			    # Data Segment Descriptor (Offset 0x10)
	.short 0xFFFF			# Limit (low 16 bits)
	.short 0x0000			# Base (low 16 bits)
	.byte 0x00				# Base (next 8 bits)
	.byte 0b10010010	    # Access byte (Read/Write, Ring 0)
	.byte 0b11001111	    # Granularity (4KB Blocks, 32-bits protected)
	.byte 0x00				# Base (high 8 bits)

user_code:                  # (Offset 0x18) zero = not present; gets a real
    .fill 8, 1, 0           # DPL 3 descriptor when ring 3 arrives

user_data:                  # (Offset 0x20) zero = not present; gets a real
    .fill 8, 1, 0           # DPL 3 descriptor when ring 3 arrives

tss_descriptor:             # TSS Descriptor (Offset 0x28)
    .short tss_end - tss_storage - 1    # Limit = 0x67 (static)
    .short 0                # Base bits 0-15  - patched at runtime
    .byte  0                # Base bits 16-23 - patched at runtime
    .byte  0x89             # Access (Present, Ring 0, 32-bit available TSS)
    .byte  0x00             # Byte granularity, limit bits 16-19 = 0
    .byte  0                # Base bits 24-31 - patched at runtime
gdt_end:

.align 4
gdt_descriptor:
    .short gdt_end - gdt_start - 1      # GDT Limit (size - 1)
    .long  gdt_start

/*  The TSS itself (104 bytes). Only three fields matter for ring
    transitions; everything else is hardware-task-switch legacy, kept 0. */
.align 4
tss_storage:
    .long 0                 # 0x00 previous task link (legacy)
    .long kernel_stack_top  # 0x04 ESP0 - stack the CPU switches to on ring 3 -> 0
    .long 0x10              # 0x08 SS0  - kernel data segment
    .fill 88, 1, 0          # 0x0C-0x63 legacy (ESP1/2, SS1/2, CR3, EIP, regs, ...)
    .short 0                # 0x64 debug trap flag
    .short tss_end - tss_storage        # 0x66 I/O map base = TSS size -> no I/O bitmap
tss_end:

/*  Dedicated kernel stack, part of the linked image. Replaces the
    bootloader's inherited 0x90000. */
.bss
.align 16
kernel_stack_bottom:
    .skip 16384             # 16 KB
kernel_stack_top:
