build_dir := $(BUILD_DIR)/$(dir)
objs := $(addprefix $(build_dir)/, $(objs-y))

$(objs): CFLAGS := $(CFLAGS) $(cflags-y)
$(output): OBJS := $(objs)
$(output): $(objs)
	$(MKDIR) -p $(@D)
	$(LD) -r -o $(@) $(OBJS)