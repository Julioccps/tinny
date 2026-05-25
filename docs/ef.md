# Exectuable Format

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
- And the rigid design from Apple's March-O.

## File Header

| Offset | Size  |   Name   | Description |
| ------ | ----- | -------- | ----------- |
|  0x00  |   4   | magic    | Magic bytes: 0x07 0x54 0x45 0x46 |
|  0x04  |   4   | version  | byte 1: Major version, byte 2: 0x2E, byte 3: Minor version, byte 4: patch number |
|  0x08  |   4   |  entry   | virtual address of the entry point of the executable |
|  0x0C  |   4   | ht_count | Number of headers defined |
|  0x10  |   4   |   flags  | Program flags (to be defined) |

