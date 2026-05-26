CC := clang
CFLAGS := -m32 -Wall -Wextra -O2 -I$(INCLUDE_DIR) -nostdlib -nostartfiles \
					-no-pie -fno-pic -ffreestanding
B_LDFLAGS := -T$(SRC_DIR)/boot/boot.ld
K_LDFLAGS := -T$(SRC_DIR)/linker.ld

SRC_DIR := src
INCLUDE_DIR := include
BUILD_DIR := build


KERNEL_SRCS := $(wildcard $(SRC_DIR)/kernel/*.c) $(wildcard $(SRC_DIR)/kernel/*.S)
BOOT_SRCS := $(wildcard $(SRC_DIR)/boot/*.c) $(wildcard $(SRC_DIR)/boot/*.S)

KERNEL_OBJS := $(patsubst $(SRC_DIR)/kernel/%, $(BUILD_DIR)/kernel/%.o, $(KERNEL_SRCS))
BOOT_OBJS := $(patsubst $(SRC_DIR)/boot/%, $(BUILD_DIR)/boot/%.o, $(BOOT_SRCS))

TARGET := tinny_os.img
KERNEL_BIN := $(BUILD_DIR)/kernel.bin
BOOT_BIN := $(BUILD_DIR)/boot.bin

.PHONY: all clean run

all: $(TARGET)

$(TARGET): $(BOOT_BIN) $(KERNEL_BIN)
	# Stitching them together with dd
	# Bootloader in first sector (512 bytes)
	dd if=$(BOOT_BIN) of=$(TARGET) conv=notrunc
	# Kernel starts at second sector
	dd if=$(KERNEL_BIN) of=$(TARGET) seek=1 conv=notrunc

$(KERNEL_BIN): $(KERNEL_OBJS)
	$(CC) $(CFLAGS) $(K_LDFLAGS) -o $@ $^

$(BOOT_BIN): $(BOOT_OBJS)
	# Bootloader likely needs its own specific linking/stripping
	$(CC) $(CFLAGS) $(B_LDFLAGS) -o $@ $^

$(BUILD_DIR)/%.o: $(SRC_DIR)/% | $(BUILD_DIR)
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR):
	mkdir -p $@

clean:
	rm -rf $(BUILD_DIR) $(TARGET)

	
