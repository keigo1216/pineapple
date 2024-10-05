ARCH = aarch64
BUILD_DIR ?= build

PROGRESS ?= echo

CC := clang
LD := ld.lld
MKDIR ?= mkdir
RM ?= rm
top_dir := $(shell pwd)

# get libs list
all_libs := $(notdir $(patsubst %/build.mk, %, $(wildcard libs/*/build.mk)))

# option of C compiler and linker
CFLAGS :=
CFLAGS += -g3 -std=c11 -ffreestanding -fno-builtin -nostdlib -nostdinc
CFLAGS += -Wall
CFLAGS += --target=aarch64-none-elf
CFLAGS += -I$(top_dir)
CFLAGS += $(foreach lib,$(all_libs),-Ilibs/$(lib)/$(ARCH))

pineapple_elf := $(BUILD_DIR)/pineapple.elf

.PHONY: all
all: $(pineapple_elf)

# rule for createing kernel
executable 		:= $(pineapple_elf)
name 			:= kernel
dir 			:= kernel
build_dir 		:= $(BUILD_DIR)/kernel
objs-y			:= 
cflags-y 		:= 
ldflags-y 		:= -T$(BUILD_DIR)/kernel/kernel.ld
libs-y			:= 
extra-deps-y 	:= $(BUILD_DIR)/kernel/kernel.ld
include kernel/build.mk
include mk/executable.mk

# qemu settings
FW_DIR := ./bcm2710-rpi-3-b-plus.dtb
QEMU := qemu-system-aarch64
MEMORY := 512
MATHINE := raspi3ap
CPU := cortex-a53

QEMU_OPTS := -M $(MATHINE) -cpu $(CPU) -m $(MEMORY) -nographic -kernel $(pineapple_elf) -dtb $(FW_DIR) -D qemu.log -serial mon:stdio --no-reboot -smp 4 -d in_asm


# # rule for library
# $(foreach lib, $(all_libs), 	\
# 	$(eval dir := libs/$(lib))	\
# 	$(eval build_dir := $(BUILD_DIR)/$(dir))	\
# 	$(eval output := $(BUILD_DIR)/libs/$(lib).o)	\
# 	$(eval objs-y := )								\
# 	$(eval cflags-y := )	\
# 	$(eval ldflags-y := )	\
# 	$(eval subdirs-y := )	\
# 	$(eval include $(dir)/build.mk)	\
# 	$(eval include $(top_dir)/mk/lib.mk)	\
# )
$(BUILD_DIR)/%.o: %.c Makefile
	$(MKDIR) -p $(@D)
	$(CC) $(CFLAGS) -c -o $@ $< -MD -MF $(@:.o=.deps) -MJ $(@:.o=.json)

$(BUILD_DIR)/%.o: %.S Makefile
	$(MKDIR) -p $(@D)
	$(CC) $(CFLAGS) -c -o $@ $< -MD -MF $(@:.o=.deps) -MJ $(@:.o=.json)

$(BUILD_DIR)/kernel/kernel.ld: kernel/$(ARCH)/kernel.ld.template
	$(MKDIR) -p $(@D)
	$(CC) $(CFLAGS) -E -x c -o $@ $<

.PHONY: run
run: $(pineapple_elf)
	$(QEMU) $(QEMU_OPTS)

.PHONY: clean
clean:
	$(RM) -rf $(BUILD_DIR)