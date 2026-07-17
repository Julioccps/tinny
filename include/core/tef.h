#ifndef TEF_H
#define TEF_H

#include <stdint.h>

#define TEF_MAGIC 0x46455407 /* "\aTEF" in little-endian */

/* File Flags */
#define TEF_FLAG_CUSTOM_MEM (1 << 0)
#define TEF_FLAG_RELOC      (1 << 1)
#define TEF_FLAG_ALIGN_4K   (1 << 2)

/* Section Types */
#define TEF_TYPE_LOAD  0
#define TEF_TYPE_BSS   1
#define TEF_TYPE_CONST 2

/* Section Flags */
#define TEF_PERM_X (1 << 0)
#define TEF_PERM_W (1 << 1)
#define TEF_PERM_R (1 << 2)
#define TEF_PERM_RWX (TEF_PERM_R | TEF_PERM_W | TEF_PERM_X)

struct _TEF_FILE_HEADER {
	uint32_t tef_magic;
	uint32_t tef_version;
	uint32_t entry_point;
	uint32_t header_table_count;
	uint32_t flags;
	uint32_t mem_size;
};

struct _TEF_PROGRAM_HEADER {
	uint32_t type;
	uint32_t vaddr;
	uint32_t offset;
	uint32_t filesz;
	uint32_t memsz;
	uint32_t flags;
};

#endif
