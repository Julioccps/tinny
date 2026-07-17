SRC_DIR := src
INCLUDE_DIR := include
BUILD_DIR := build

# CC and AS use := because they are built-in make variables (default cc/as);
# ?= would not override make's built-in value. Command-line overrides still win.
CC      := clang
AS      := nasm
OBJCOPY ?= objcopy
# TRIPLE: leave empty on a host whose clang already targets ELF (Linux).
# On a host that defaults elsewhere (e.g. Windows/MSVC), set an ELF target,
# e.g. `make TRIPLE=i686-unknown-linux-gnu OBJCOPY=llvm-objcopy`, which makes
# clang emit ELF, honor the linker script, and link with ld.lld.
TRIPLE  ?=
ASFLAGS := -f bin
CFLAGS := -m32 -Wall -Wextra -O2 -I$(INCLUDE_DIR) -nostdlib -nostartfiles \
				-no-pie -fno-pic -ffreestanding $(if $(TRIPLE),--target=$(TRIPLE))
K_LDFLAGS := -T$(SRC_DIR)/linker.ld $(if $(TRIPLE),-fuse-ld=lld)

KERNEL_SRCS_C := $(wildcard $(SRC_DIR)/kernel/*.c)
KERNEL_SRCS_S := $(wildcard $(SRC_DIR)/kernel/*.S)
KERNEL_OBJS := $(patsubst $(SRC_DIR)/%.c, $(BUILD_DIR)/%.o, $(KERNEL_SRCS_C)) \
               $(patsubst $(SRC_DIR)/%.S, $(BUILD_DIR)/%.o, $(KERNEL_SRCS_S))

TARGET := tinny_os.img
KERNEL_ELF := $(BUILD_DIR)/kernel.elf
KERNEL_BIN := $(BUILD_DIR)/kernel.bin
BOOT_BIN := $(BUILD_DIR)/boot.bin
BOOT_SRC := $(SRC_DIR)/boot/bootloader.asm

.PHONY: all clean run

all: $(TARGET)

$(TARGET): $(BOOT_BIN) $(KERNEL_BIN)
	dd if=$(BOOT_BIN) of=$(TARGET) conv=notrunc
	dd if=$(KERNEL_BIN) of=$(TARGET) seek=1 conv=notrunc
	truncate -s 33280 $(TARGET)

$(KERNEL_BIN): $(KERNEL_ELF)
	$(OBJCOPY) -O binary $< $@

$(KERNEL_ELF): $(KERNEL_OBJS)
	$(CC) $(CFLAGS) $(K_LDFLAGS) -o $@ $^

$(BOOT_BIN): $(BOOT_SRC) | $(BUILD_DIR)
	$(AS) $(ASFLAGS) $< -o $@

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c | $(BUILD_DIR)
	mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.S | $(BUILD_DIR)
	mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR):
	mkdir -p $@

clean:
	rm -rf $(BUILD_DIR) $(TARGET)

run: $(TARGET)
	qemu-system-i386 -drive format=raw,file=$(TARGET) -m 512M -no-reboot -d int 2>&1 | head -50
