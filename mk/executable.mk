# get subdir object file
build_dir := $(BUILD_DIR)/$(dir)
objs := $(addprefix $(build_dir)/, $(objs-y))
dir-saved = $(dir)
$(foreach subdir, $(subdirs-y),					\
	$(eval dir := $(dir-saved)/$(subdir))		\
	$(eval build_dir := $(BUILD_DIR)/$(dir))	\
	$(eval objs-y := )							\
	$(eval include $(dir)/build.mk)				\
	$(eval objs += $(addprefix $(build_dir)/, $(objs-y)))	\
)

objs := \
	$(objs) \
	$(foreach lib, $(libs-y), $(BUILD_DIR)/libs/$(lib).o)

$(objs): CFLAGS := $(CFLAGS) $(cflags-y)

$(executable): LDFLAGS := $(LDFLAGS) $(ldflags-y)
$(executable): OBJS := $(objs)
$(executable): NAME:= $(name)
$(executable): $(objs) $(extra-deps-y)
	$(MKDIR) -p $(@D)
	$(LD) $(LDFLAGS) -Map $(@:.elf=.map) -o $(@) $(OBJS)