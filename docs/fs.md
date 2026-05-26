# File System

I'm inspired by ext2 for this one, I've been reading about it and the idea of
index nodes rather than a file table makes much more sense and it's a great
solution for fragmentation.

## Data Structures

- Inodes(Index Nodes):
    - The root of all, be it a directory or a file, the representation is
      through an inode.

| Size | Name   | Description |
| ---- | ------ | ----------- |
|  2   | mode   | Permision + type (file or dir) |
|  2   | nlinks | Number of names pointing to this inode |
|  4   | uid    | Owner ID    |
|  4   | gid    | Group ID    |
|  4   | size   | File size in bytes |
|  8   | atime  | Access time |
|  8   | mtime  | Modify time |
|  8   | ctime  | Create time |
|  48  | blocks | 12 direct pointers (4 bytes each) |
|  4   | iblock | 1 indirect pointer |

> OBS.: I'll do time with 64 bits, so I don't have an expiration date for my
> files

## Superblock
The Superblock defines the global state of the filesystem. Located at Sector 1 (Sector 0 is Boot).

| Size | Name          | Description |
| ---- | ------------- | ----------- |
|  4   | magic         | Magic number: 0x1C 0x54 0x46 0x53 |
|  4   | version       | FS version |
|  4   | total_blocks  | Total number of blocks on disk |
|  4   | total_inodes  | Total number of inode slots |
|  4   | free_blocks   | Number of available blocks |
|  4   | free_inodes   | Number of available inodes |
|  4   | block_size    | Size of a single block (e.g., 1024, 4096) |

## Directory Entry
Directory entries are stored within the data blocks of an "Inode Type: Directory". They map a filename to an Inode number.

| Size | Name     | Description |
| ---- | -------- | ----------- |
|  4   | inode    | Inode number |
|  2   | rec_len  | Length of this record (for variable-length names) |
|  1   | name_len | Length of the filename |
|  1   | file_type| 1: File, 2: Directory |
|  v   | name     | Filename (variable length, null terminated) |

## Disk Layout (Overview)
1.  **Boot Sector** (512 bytes)
2.  **Superblock** (1 block)
3.  **Inode Bitmap** (1 block)
4.  **Block Bitmap** (1 block)
5.  **Inode Table** (N blocks)
6.  **Data Blocks** (The rest)


