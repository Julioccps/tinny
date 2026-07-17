ENTRY(_start)

SECTIONS{
	. = 1M;

	.text : {
		*(.text.boot)	/* entry point first — bootloader jmps to 0x100000 */
		*(.text)
	}

	.data : {
		*(.data)
	}

	.bss : {
		*(.bss)
		*(COMMON)
	}
}
