ARCH = aarch64
BUILD_DIR ?= build

PROGRESS ?= echo

CC := clang
MKDIR ?= mkdir
RM ?= rm
top_dir := $(shell pwd)

# option of C compiler and linker
CFLAGS :=
CFLAGS += -I $(top_dir)

.PHONY: all
all: $(BUILD_DIR)/kernel/kernel.ld

$(BUILD_DIR)/kernel/kernel.ld: kernel/$(ARCH)/kernel.ld.template
	$(MKDIR) -p $(@D)
	$(CC) $(CFLAGS) -E -x c -o $@ $<

.PHONY: clean
clean:
	$(RM) -rf $(BUILD_DIR)