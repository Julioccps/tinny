#ifndef TEF_H
#define TEF_H

#include "utils/type.h"

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
	u32_t tef_magic;
	u32_t tef_version;
	u32_t entry_point;
	u32_t header_table_count;
	u32_t flags;
	u32_t mem_size;
};

struct _TEF_PROGRAM_HEADER {
	u32_t type;
	u32_t vaddr;
	u32_t offset;
	u32_t filesz;
	u32_t memsz;
	u32_t flags;
};

#endif
