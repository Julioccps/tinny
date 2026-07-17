#ifndef TFS_H
#define TFS_H

#include <stdint.h>

#define TFS_MAGIC 0x1C544653 /* 0x1CTFS */

struct tfs_inode {
	uint16_t mode;
	uint16_t nlinks;
	uint32_t uid;
	uint32_t gid;
	uint32_t size;
	uint64_t atime;
	uint64_t mtime;
	uint64_t ctime;
	uint32_t blocks[12];   /* 12 direct pointers. Conventions: for device
	                     * inodes blocks[0] holds major/minor; for short
	                     * symlinks (< 52 bytes) the target is stored
	                     * inline in this whole pointer area */
	uint32_t indirect;     /* single-indirect pointer */
	uint32_t dindirect;    /* double-indirect pointer (v1: reserved, not
	                     * implemented -- driver must reject, not ignore) */
	uint32_t flags;        /* immutable / append-only / no-atime, etc. */
	uint32_t nblocks;      /* allocated block count (sparse files, st_blocks) */
	uint32_t checksum;     /* CRC of this inode, computed with this field = 0 */
	uint8_t  reserved[20]; /* zero-filled, room for v2 */
}__attribute__((aligned(128)));
/* Forcing memory to align struct to 128 bytes: fields sum to 108, the
 * reserved bytes bring it to exactly 128 -> 32 inodes per 4KB block. */
_Static_assert(sizeof(struct tfs_inode) == 128, "on-disk inode must be 128 bytes");

struct tfs_superblock {
	uint32_t magic;
	uint32_t version;
	uint32_t total_blocks;
	uint32_t total_inodes;
	uint32_t free_blocks;
	uint32_t free_inodes;
	uint32_t block_size;
};

struct tfs_dir_entry {
	uint32_t inode;
	uint16_t rec_len;
	uint8_t  name_len;
	uint8_t  file_type;
	char  name[]; /* Flexible array member for variable name */
};

#endif
