
#
# Global build system definitions go here
#

ifndef TEGRA_ROOT
TEGRA_ROOT := vendor/nvidia/tegra/core
endif

NVIDIA_BUILD_ROOT          := vendor/nvidia/build

# links to build system files

NVIDIA_BASE                := $(NVIDIA_BUILD_ROOT)/base.mk
NVIDIA_DEFAULTS            := $(NVIDIA_BUILD_ROOT)/defaults.mk
NVIDIA_STATIC_LIBRARY      := $(NVIDIA_BUILD_ROOT)/static_library.mk
NVIDIA_SHARED_LIBRARY      := $(NVIDIA_BUILD_ROOT)/shared_library.mk
NVIDIA_EXECUTABLE          := $(NVIDIA_BUILD_ROOT)/executable.mk
NVIDIA_STATIC_AND_SHARED_LIBRARY := $(NVIDIA_BUILD_ROOT)/static_and_shared_library.mk
NVIDIA_HOST_STATIC_LIBRARY := $(NVIDIA_BUILD_ROOT)/host_static_library.mk
NVIDIA_HOST_SHARED_LIBRARY := $(NVIDIA_BUILD_ROOT)/host_shared_library.mk
NVIDIA_HOST_EXECUTABLE     := $(NVIDIA_BUILD_ROOT)/host_executable.mk
NVIDIA_JAVA_LIBRARY        := $(NVIDIA_BUILD_ROOT)/java_library.mk
NVIDIA_PACKAGE             := $(NVIDIA_BUILD_ROOT)/package.mk

# tools

NVIDIA_CGC		   := $(TEGRA_ROOT)/../cg/Cg/$(HOST_OS)/cgc
NVIDIA_AR20ASM		   := $(TEGRA_ROOT)/../cg/Cg/$(HOST_OS)/ar20asm

NVIDIA_HEXIFY	           := $(NVIDIA_BUILD_ROOT)/hexify.py
NVIDIA_GETEXPORTS          := $(NVIDIA_BUILD_ROOT)/getexports.py
NVIDIA_SHADERFIX	   := $(HOST_OUT_EXECUTABLES)/shaderfix
ifneq ($(TEGRA_ROOT),hardware/tegra)
NVIDIA_NVIDL		   := $(HOST_OUT_EXECUTABLES)/nvidl
else
NVIDIA_NVIDL		   := hardware/tegra/prebuilt/host/$(HOST_OS)-x86/bin/nvidl
endif

# global vars
ALL_NVIDIA_MODULES :=
ALL_NVIDIA_TESTS :=
ifneq ($(TEGRA_ROOT),hardware/tegra)
NVIDIA_APICHECK := 1
endif

# rule generation to be used via $(call)

define nvidl-rule
$(3): PRIVATE_IDLFLAGS := $(1) $(LOCAL_IDLFLAGS) $(addprefix -I ,$(LOCAL_IDL_INCLUDES))
$(3): $(2) $(NVIDIA_NVIDL) $(LOCAL_ADDITIONAL_DEPENDENCIES)
	@echo "IDL Generated file: $$@"
	@mkdir -p $$(dir $$@)
	$(hide) $(NVIDIA_NVIDL) $$(PRIVATE_IDLFLAGS) -o $$@ $$<
endef

define transform-shader-to-cgbin
@echo "Compiling shader $@ from $<"
@mkdir -p $(@D)
$(hide) cat $< | $(NVIDIA_CGC) -quiet $(PRIVATE_CGOPTS) -o $(basename $@).cgbin
endef

define transform-cgbin-to-cghex
@echo "Generating shader binary $@ from $<"
@mkdir -p $(@D)
$(hide) $(NVIDIA_SHADERFIX) -o $(basename $@).ar20bin $(basename $@).cgbin
$(hide) $(NVIDIA_HEXIFY) $(basename $@).ar20bin $@
endef

define transform-cgbin-to-h
@echo "Generating non-shaderfixed binary $@ from $<"
@mkdir -p $(@D)
$(hide) $(NVIDIA_HEXIFY) $(basename $@).cgbin $@
endef

define transform-shader-to-string
@echo "Generating shader source $@ from $<"
@mkdir -p $(@D)
$(hide) cat $< | sed -e 's|^.*$$|"&\\n"|' > $@
endef

define transform-ar20asm-to-h
@echo "Generating shader $@ from $<"
$(hide) LD_LIBRARY_PATH=$(TEGRA_ROOT)/../cg/Cg/linux $(NVIDIA_AR20ASM) $< $(basename $@).ar20bin
$(hide) $(NVIDIA_HEXIFY) $(basename $@).ar20bin $@
endef

define shader-rule
# shaders and shader source to output
SHADERS_COMPILE_$(1) := $(addprefix $(intermediates)/shaders/, \
	$(patsubst %.$(1),%.cgbin,$(filter %.$(1),$(2))))
GEN_SHADERS_COMPILE_$(1) := $(addprefix $(intermediates)/shaders/, \
	$(patsubst %.$(1),%.cgbin,$(filter %.$(1),$(3))))
SHADERS_$(1) := $(addprefix $(intermediates)/shaders/, \
	$(patsubst %.$(1),%.cghex,$(filter %.$(1),$(2))))
GEN_SHADERS_$(1) := $(addprefix $(intermediates)/shaders/, \
	$(patsubst %.$(1),%.cghex,$(filter %.$(1),$(3))))
SHADERS_NOFIX_$(1) := $(addprefix $(intermediates)/shaders/, \
	$(patsubst %.$(1),%.h,$(filter %.$(1),$(2))))
GEN_SHADERS_NOFIX_$(1) := $(addprefix $(intermediates)/shaders/, \
	$(patsubst %.$(1),%.h,$(filter %.$(1),$(3))))
SHADERSRC_$(1) := $(addprefix $(intermediates)/shaders/, \
	$(patsubst %.$(1),%.$(1)h,$(filter %.$(1),$(2))))
GEN_SHADERSRC_$(1) := $(addprefix $(intermediates)/shaders/, \
	$(patsubst %.$(1),%.$(1)h,$(filter %.$(1),$(3))))

# create lists to "output"
ALL_SHADERS_COMPILE_$(1) := $$(SHADERS_COMPILE_$(1)) $$(GEN_SHADERS_COMPILE_$(1))
ALL_SHADERS_$(1) := $$(SHADERS_$(1)) $$(GEN_SHADERS_$(1))
ALL_SHADERS_NOFIX_$(1) := $$(SHADERS_NOFIX_$(1)) $$(GEN_SHADERS_NOFIX_$(1))
ALL_SHADERSRC_$(1) := $$(SHADERSRC_$(1)) $$(GEN_SHADERSRC_$(1))

# rules for building the shaders and shader source
$$(SHADERS_COMPILE_$(1)): $(intermediates)/shaders/%.cgbin : $(LOCAL_PATH)/%.$(1)
	$$(transform-shader-to-cgbin)
$$(GEN_SHADERS_COMPILE_$(1)): $(intermediates)/shaders/%.cgbin : $(intermediates)/%.$(1)
	$$(transform-shader-to-cgbin)
$$(SHADERS_$(1)): $(intermediates)/shaders/%.cghex : $(intermediates)/shaders/%.cgbin
	$$(transform-cgbin-to-cghex)
$$(GEN_SHADERS_$(1)): $(intermediates)/shaders/%.cghex : $(intermediates)/shaders/%.cgbin
	$$(transform-cgbin-to-cghex)
$$(SHADERS_NOFIX_$(1)): $(intermediates)/shaders/%.h : $(intermediates)/shaders/%.cgbin
	$$(transform-cgbin-to-h)
$$(GEN_SHADERS_NOFIX_$(1)): $(intermediates)/shaders/%.h : $(intermediates)/shaders/%.cgbin
	$$(transform-cgbinr-to-h)
$$(SHADERSRC_$(1)): $(intermediates)/shaders/%.$(1)h : $(LOCAL_PATH)/%.$(1)
	$$(transform-shader-to-string)
$$(GEN_SHADERSRC_$(1)): $(intermediates)/shaders/%.$(1)h : $(intermediates)/%.$(1)
	$$(transform-shader-to-string)
endef

