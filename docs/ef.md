# Executable Format

I'm going towards a mixture of various approaches, I'll borrow a thing or two
from other implementations of executable formats.

## Features

- First, rigid section design:
```
  Pre-Program
+----------------------+
|     File Header      |
+----------------------+
| Program Header table |
+----------------------+
  .text, Actual Program
+----------------------+
|      Section 1       |
+----------------------+
|         ...          |
+----------------------+
|      Section n       |
+----------------------+
  .data, Program Data
+----------------------+
|       _data          |
+----------------------+
|       _const         |
+----------------------+
|       _bss           |
+----------------------+
```
- The idea of a header table comes from Microsoft's PE design;
- The idea of supporting multiple sections from ELF;
- And the rigid design from Apple's Mach-O.

## File Header

| Offset | Size  |   Name   | Description |
| ------ | ----- | -------- | ----------- |
|  0x00  |   4   | magic    | Magic bytes: 0x07 0x54 0x45 0x46 |
|  0x04  |   4   | version  | byte 1: Major version, byte 2: 0x2E, byte 3: Minor version, byte 4: patch number |
|  0x08  |   4   |  entry   | virtual address of the entry point of the executable |
|  0x0C  |   4   | ht_count | Number of headers defined |
|  0x10  |   4   |   flags  | Program flags (see below) |
|  0x14  |   4   | mem_size | Total RAM footprint (inc. Stack/BSS). If 0, use Kernel Default. |

## Flags

| Bit | Name             | Description |
| --- | ---------------- | ----------- |
|  0  | HAS_CUSTOM_MEM   | If set, loader must respect `mem_size` |
|  1  | RELOCATABLE      | **Reserved for v2** (see OBS. below) |
|  2  | STRICT_ALIGN     | Enforce 4KB page alignment for sections |

> OBS.: `RELOCATABLE` is reserved because the format does not define a
> relocation table yet — a loader would have no way to fix up absolute
> addresses inside the binary. Until v2 specs one (or mandates PIC code
> for the flag), v1 binaries load at the `vaddr` in their program headers
> and v1 loaders must reject a binary with this bit set.

## Program Header Table Entry

Each entry in the table describes a single section (e.g., .text, .data).

| Offset | Size | Name   | Description |
| ------ | ---- | ------ | ----------- |
|  0x00  |  4   | type   | Section type (0: LOAD, 1: BSS, 2: CONST) |
|  0x04  |  4   | vaddr  | Target virtual address |
|  0x08  |  4   | offset | Offset of section data within the file |
|  0x0C  |  4   | filesz | Size of the section in the file |
|  0x10  |  4   | memsz  | Size of the section in memory |
|  0x14  |  4   | flags  | Permissions (e.g., 0x7 for LOAD/RWX, 0x5 for CONST/RX) |

