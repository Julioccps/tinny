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
	u32_t blocks[12];
	u32_t indirect;
}__attribute__((aligned(128))); 
/* Forcing it to be all zeros until 128 bytes
 * TODO look into adding more data to store*/

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
