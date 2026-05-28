SRC_DIR := src
INCLUDE_DIR := include
BUILD_DIR := build

CC := clang
AS := nasm
ASFLAGS := -f bin
CFLAGS := -m32 -Wall -Wextra -O2 -I$(INCLUDE_DIR) -nostdlib -nostartfiles \
				-no-pie -fno-pic -ffreestanding
K_LDFLAGS := -T$(SRC_DIR)/linker.ld

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
	objcopy -O binary $< $@

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
