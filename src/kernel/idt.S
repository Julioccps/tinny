/*  idt.S — one Interrupt Descriptor Table for the whole kernel.

      vectors 0-31    CPU exceptions  -> per-vector stubs, halt on fault
      vectors 32-255  unexpected      -> default stub, halt
      vector  0x80    syscall gate    -> syscall_handler (in k_setup.S)

    idt_start is just zeroed storage; idt_setup writes the live gates at
    runtime. The gates cannot be built at link time because a 32-bit handler
    address must be split into hi/lo 16-bit halves, and the linker only
    relocates a symbol as a whole, never a 16-bit slice of one. That is the
    same reason the old syscall_setup split the address with shrl at runtime.
*/
.globl idt_setup

/* --- exception stub macros ------------------------------------------- */
/* Vectors that do NOT push a CPU error code: push a dummy 0 so every
   isr_common frame is identical: [vector][errcode][eip][cs][eflags]. */
.macro ISR_NOERR num
isr\num:
    pushl $0
    pushl $\num
    jmp   isr_common
.endm

/* Vectors that DO push an error code: only add the vector number. */
.macro ISR_ERR num
isr\num:
    pushl $\num
    jmp   isr_common
.endm

.text
/* 0-31: the architecturally defined exceptions. 8, 10-14, 17 and 21 push an
   error code; the rest do not (22-31 are reserved but wired for safety). */
ISR_NOERR 0
ISR_NOERR 1
ISR_NOERR 2
ISR_NOERR 3
ISR_NOERR 4
ISR_NOERR 5
ISR_NOERR 6
ISR_NOERR 7
ISR_ERR   8
ISR_NOERR 9
ISR_ERR   10
ISR_ERR   11
ISR_ERR   12
ISR_ERR   13
ISR_ERR   14
ISR_NOERR 15
ISR_NOERR 16
ISR_ERR   17
ISR_NOERR 18
ISR_NOERR 19
ISR_NOERR 20
ISR_ERR   21
ISR_NOERR 22
ISR_NOERR 23
ISR_NOERR 24
ISR_NOERR 25
ISR_NOERR 26
ISR_NOERR 27
ISR_NOERR 28
ISR_NOERR 29
ISR_NOERR 30
ISR_NOERR 31

/* Landing pad for the exceptions. For now: mask interrupts and halt so a
   fault becomes a clean stop instead of escalating toward a triple fault.
   The vector number and error code sit on the stack for a future handler. */
isr_common:
    cli
    hlt
    jmp   isr_common

/* Any vector we never explicitly set up (32-255, minus the syscall gate). */
isr_default:
    cli
    hlt
    jmp   isr_default

/* --- installer ------------------------------------------------------- */
/* install_gate: write one 8-byte gate descriptor.
     %eax = handler address (clobbered by the hi/lo split)
     %edi = pointer to the target slot
     %dl  = type/attribute byte
   Selector is always 0x08, the bootloader GDT code segment. */
install_gate:
    movw  %ax, 0(%edi)          # offset bits 0-15
    movw  $0x0008, 2(%edi)      # segment selector
    movb  $0x00, 4(%edi)        # reserved
    movb  %dl, 5(%edi)          # type + attributes
    shrl  $16, %eax
    movw  %ax, 6(%edi)          # offset bits 16-31
    ret

idt_setup:
    # 1) Fill all 256 slots with the default halt stub first, so no gate is
    #    ever "not present" — a fault through a missing gate triple-faults.
    movl  $idt_start, %edi
    movl  $256, %ecx
    movb  $0x8E, %dl            # present, ring 0, 32-bit interrupt gate
.Lfill_default:
    movl  $isr_default, %eax
    call  install_gate
    addl  $8, %edi
    loop  .Lfill_default

    # 2) Overwrite vectors 0-31 with the real exception stubs. The loop walks
    #    isr_stub_table because ISR_ERR and ISR_NOERR stubs differ in length,
    #    so the stub addresses are not evenly spaced.
    movl  $idt_start, %edi
    movl  $isr_stub_table, %esi
    movl  $32, %ecx
    movb  $0x8E, %dl
.Lfill_exc:
    movl  (%esi), %eax
    call  install_gate
    addl  $4, %esi
    addl  $8, %edi
    loop  .Lfill_exc

    # 3) Install the syscall gate at vector 0x80 (slot 128), ring 3 reachable.
    #    0xEF preserves the attribute byte the old syscall_setup used.
    movl  $syscall_handler, %eax
    movl  $idt_start + 1024, %edi   # 128 * 8
    movb  $0xEF, %dl
    call  install_gate

    # 4) Point the CPU at the finished table.
    lidt  idt_descriptor
    ret

.data
.align 4
isr_stub_table:
    .long isr0,  isr1,  isr2,  isr3,  isr4,  isr5,  isr6,  isr7
    .long isr8,  isr9,  isr10, isr11, isr12, isr13, isr14, isr15
    .long isr16, isr17, isr18, isr19, isr20, isr21, isr22, isr23
    .long isr24, isr25, isr26, isr27, isr28, isr29, isr30, isr31

.align 8
idt_start:
    .fill 2048, 1, 0           # 256 gates * 8 bytes, all written at runtime

.align 4
idt_descriptor:
    .short 2048 - 1            # limit = 256 * 8 - 1 = 0x07FF
    .long  idt_start
