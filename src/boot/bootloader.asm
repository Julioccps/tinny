[BITS 16]
[ORG 0x7C00]

_start:
	; Clean up segment registers
	xor ax, ax
	mov ds, ax
	mov es, ax
	mov ss, ax
	mov sp, 0x7C00

	mov [boot_drive], dl ; Save the boot drive
	mov bx, 0xDEAD	; Magic value to verify we reached _start

	; Load Kernel sectors into the 64KB staging buffer
	mov ah, 0x02
	mov al, 0x40
	xor ch, ch
	mov cl, 0x02
	xor dh, dh
	mov dl, [boot_drive]
	mov bx, 0x1000
	mov es, bx
	xor bx, bx
	int 0x13
	jc disk_error
	; Enable A20 Line (Using the Fast A20 method via system control port)
	in al, 0x92
	or al, 0x02
	out 0x92, al
	; Disable Interrupts and Load GDT
	cli	; Disable BIOS Interrupts before leaving Real Mode
	lgdt [gdt_descriptor]
	; Turn ON Protected Mode (Set bit 0 of CR0)
	mov eax, cr0
	or eax, 1
	mov cr0, eax
	; Execute 32-bit far jump to flush the 16-bit pipeline
	; 0x08 points to Code Segment Descriptor of GDT
	jmp 0x08:init_pm

disk_error:
	cli	; Disable BIOS Interrupts before halting
	mov si, error_msg
	call print_str
	jmp $

print_str:
	lodsb
	or al, al
	jz .done
	mov ah, 0x0E
	xor bh, bh
	int 0x10
	jmp print_str
.done:
	ret

[BITS 32]
init_pm:
	; 32-bit data segment setup
	mov ax, 0x10
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	mov ss, ax
	mov esp, 0x90000
	; Copy the Kernel's entry point
	mov esi, 0x10000
	mov edi, 0x100000
	mov ecx, 0x2000 ; 8192 for non-computers
	rep movsd
	; Jump to the Kernel
	jmp 0x100000

; Flat Model GDT Data Structures
gdt_start:
	dd 0x0	; Null Descriptor (Required)
	dd 0x0

gdt_code:				; Code Segment Descriptor (Offset 0x08)
	dw 0xFFFF			; Limit (low 16 bits)
	dw 0x0000			; Base (low 16 bits)
	db 0x00				; Base (next 8 bits)
	db 10011010b	    ; Access byte (Exec/Read, Ring 0)
	db 11001111b	    ; Granularity (4KB Blocks, 32-bits protected)
	db 0x00				; Base (high 8 bits)

gdt_data:				; Data Segment Descriptor (Offset 0x10)
	dw 0xFFFF			; Limit (low 16 bits)
	dw 0x0000			; Base (low 16 bits)
	db 0x00				; Base (next 8 bits)
	db 10010010b	    ; Access byte (Read/Write, Ring 0)
	db 11001111b	    ; Granularity (4KB Blocks, 32-bits protected)
	db 0x00				; Base (high 8 bits)

gdt_end:

gdt_descriptor:
	dw gdt_end - gdt_start - 0x01
	dd gdt_start

error_msg db "Disk Error", 0x0A, 0x00
boot_drive db 0x00
times 510-($-$$) db 0x00
dw 0xAA55
