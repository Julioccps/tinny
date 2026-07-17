ENTRY(_start)

SECTIONS{
	. = 1M;

	.text : {
		*(.text.boot)	/* entry point first — bootloader jmps to 0x100000 */
		*(.text)
	}

	/* Read-only data (string literals, switch jump tables). Must be placed
	   explicitly and AFTER .text, or lld orphans it ahead of .text.boot and
	   the bootloader jumps into a jump table instead of _start. */
	.rodata : {
		*(.rodata*)
		*(.data.rel.ro*)
	}

	.data : {
		*(.data)
	}

	.bss : {
		*(.bss)
		*(COMMON)
	}
}
