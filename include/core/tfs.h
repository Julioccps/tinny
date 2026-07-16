#ifndef TFS_H
#define TFS_H

#include "utils/type.h"

#define TFS_MAGIC 0x1C544653 /* 0x1CTFS */

struct tfs_inode {
	u16_t mode;
	u16_t nlinks;
	u32_t uid;
	u32_t gid;
	u32_t size;
	u64_t atime;
	u64_t mtime;
	u64_t ctime;
	u32_t blocks[12];   /* 12 direct pointers. Conventions: for device
	                     * inodes blocks[0] holds major/minor; for short
	                     * symlinks (< 52 bytes) the target is stored
	                     * inline in this whole pointer area */
	u32_t indirect;     /* single-indirect pointer */
	u32_t dindirect;    /* double-indirect pointer (v1: reserved, not
	                     * implemented -- driver must reject, not ignore) */
	u32_t flags;        /* immutable / append-only / no-atime, etc. */
	u32_t nblocks;      /* allocated block count (sparse files, st_blocks) */
	u32_t checksum;     /* CRC of this inode, computed with this field = 0 */
	u8_t  reserved[20]; /* zero-filled, room for v2 */
}__attribute__((aligned(128)));
/* Forcing memory to align struct to 128 bytes: fields sum to 108, the
 * reserved bytes bring it to exactly 128 -> 32 inodes per 4KB block. */
_Static_assert(sizeof(struct tfs_inode) == 128, "on-disk inode must be 128 bytes");

struct tfs_superblock {
	u32_t magic;
	u32_t version;
	u32_t total_blocks;
	u32_t total_inodes;
	u32_t free_blocks;
	u32_t free_inodes;
	u32_t block_size;
};

struct tfs_dir_entry {
	u32_t inode;
	u16_t rec_len;
	u8_t  name_len;
	u8_t  file_type;
	char  name[]; /* Flexible array member for variable name */
};

#endif
