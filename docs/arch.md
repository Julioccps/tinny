# Tinny Architecture

Tinny is a 32-bit x86 Unix-like operating system designed for simplicity, modularity, and educational clarity. It features a monolithic kernel structure with custom standards for executables and filesystem storage.

## 1. Design Philosophy
- **Monolithic Core:** A single kernel image handles memory management, process scheduling, and hardware abstraction.
- **Custom Standards:** Uses the **TEF** (Tinny Executable Format) and **TFS** (Tinny File System) to maintain a cohesive and well-understood system boundary.
- **Hardware-Enforced Security:** Clear separation between Kernel Mode (Ring 0) and User Mode (Ring 3) using x86 protection features.

## 2. System Boot Sequence
The boot process follows a three-stage transition from hardware initialization to kernel execution:

1.  **Stage 1 (Bootloader):** The BIOS loads the first 512-byte sector (MBR) at `0x7C00`. This stage is responsible for:
    - Enabling the A20 line.
    - Loading the Stage 2/Kernel from disk.
    - Transitioning the CPU from 16-bit Real Mode to 32-bit Protected Mode.
2.  **Stage 2 (Kernel Initialization):** The kernel begins execution at its entry point (`_start`) loaded at the 1MB mark (`0x00100000`). See [kernel.md](kernel.md) for the full bring-up contract.
    - Switches to the kernel's own 16KB stack (lives in `.bss`, part of the image).
    - Installs the kernel's own GDT (retiring the bootloader's scaffolding one) and loads the TSS via `ltr`.
    - Installs the IDT: exception stubs for vectors 0-31, default handlers for the rest, syscall gate at `0x80`.
    - *(Planned)* Initializes the physical and virtual memory managers.
    - Calls `kmain`.
3.  **Stage 3 (User Space):** The kernel mounts the root TFS filesystem, loads the `init` process (in TEF format), and enters Ring 3.

## 3. Memory Management
Tinny utilizes x86 Paging to provide process isolation and virtual memory mapping.

### Physical Memory Map (Typical)
| Address Range | Description |
|---------------|-------------|
| `0x00000000` - `0x000003FF` | BIOS Interrupt Vector Table (Real Mode) |
| `0x00007C00` - `0x00007DFF` | Bootloader Load Address |
| `0x00010000` - `0x00017FFF` | Kernel staging buffer (bootloader loads here, then copies to 1MB) |
| `0x000B8000` - `0x000BFFFF` | VGA Text Buffer (Video Memory) |
| `0x00100000` - `0x003FFFFF` | Kernel Code and Data (Static) |
| `0x00400000` +              | Dynamic Allocation (Heap/User Pages) |

> OBS.: The kernel's stack, GDT, TSS and IDT all live *inside* the kernel
> image (`.data`/`.bss` at 1MB+). The bootloader-era stack at `0x90000` is
> abandoned the moment `_start` runs.

### Virtual Memory
- **Kernel Space:** Mapped into the higher half of the virtual address space (planned for `0xC0000000` — but see Open Decisions below, this is not final).
- **User Space:** Each process occupies a private virtual address space starting from low memory.

## 4. Executable Format (TEF)
All binaries in Tinny follow the **Tinny Executable Format**.
- **Section-Based:** Support for `.text` (code), `.data` (initialized), and `.bss` (uninitialized) sections.
- **Strict Alignment:** Optional 4KB alignment for paging efficiency.
- **Loader Contract:** The kernel parses the TEF header, maps the requested memory segments, and sets the instruction pointer to the defined `entry_point`.

## 5. File System (TFS)
The **Tinny File System** is an inode-based filesystem inspired by `ext2`.
- **Index Nodes:** Every file/directory is represented by a `tfs_inode` containing metadata and 12 direct block pointers.
- **64-bit Timestamps:** Future-proofed against the "Year 2038" problem.
- **Disk Layout:**
  1. Boot Sector (Sector 0)
  2. Superblock (Global FS State)
  3. Bitmaps (Inode and Block availability)
  4. Inode Table
  5. Data Blocks

## 6. System Call Interface
The boundary between user programs and the kernel is managed via software interrupts (`int 0x80`).
- **Calling Convention:** Register-based for performance.
  - `EAX`: Syscall Number.
  - `EBX, ECX, EDX, ESI, EDI`: Arguments.
  - `EAX`: Return value (Negative for errors).
- **LibC Bridge:** The `tinasm.h` component provides thin assembly wrappers around these interrupts to expose a C-compatible API.

## 7. Development Roadmap

The roadmap lives in the [README](../README.md#roadmap) — single source of
truth, this document does not duplicate it.

## 8. Open Decisions

Decisions that must be made deliberately, not by default:

1. **Identity-mapped vs higher-half kernel (`0xC0000000`).** Must be decided
   before paging and `mmap`/`brk` are implemented — retrofitting higher-half
   later touches the linker script and every absolute address in the kernel.
2. **TEF relocation.** The `RELOCATABLE` flag is reserved until a relocation
   table is actually specified (see [ef.md](ef.md)).
3. **Networking transport.** No RJ-45 on the target machine, so a USB stack
   is a prerequisite either way; USB-Ethernet vs Wi-Fi is decided when the
   USB stack exists.
