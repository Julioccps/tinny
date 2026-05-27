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
2.  **Stage 2 (Kernel Initialization):** The kernel begins execution at its entry point (`_start`) loaded at the 1MB mark (`0x00100000`).
    - Sets up the Global Descriptor Table (GDT) and Interrupt Descriptor Table (IDT).
    - Initializes the physical and virtual memory managers.
3.  **Stage 3 (User Space):** The kernel mounts the root TFS filesystem, loads the `init` process (in TEF format), and enters Ring 3.

## 3. Memory Management
Tinny utilizes x86 Paging to provide process isolation and virtual memory mapping.

### Physical Memory Map (Typical)
| Address Range | Description |
|---------------|-------------|
| `0x00000000` - `0x000003FF` | BIOS Interrupt Vector Table (Real Mode) |
| `0x00007C00` - `0x00007DFF` | Bootloader Load Address |
| `0x000B8000` - `0x000BFFFF` | VGA Text Buffer (Video Memory) |
| `0x00100000` - `0x003FFFFF` | Kernel Code and Data (Static) |
| `0x00400000` +              | Dynamic Allocation (Heap/User Pages) |

### Virtual Memory
- **Kernel Space:** Mapped into the higher half of the virtual address space (planned for `0xC0000000`).
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
- **Phase 0:** Specification and Design (Current).
- **Phase 1:** Bootloader and Basic Kernel Entry.
- **Phase 2:** Memory Management and Paging.
- **Phase 3:** TFS Driver and File I/O.
- **Phase 4:** Process Management and Multitasking.
- **Phase 5:** User-space LibC and Shell.
