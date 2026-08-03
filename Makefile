
KERNEL_SRC ?= /lib/modules/$(shell uname -r)/build
DTC ?= $(shell command -v dtc)
OVERLAY_INSTALL_DIR ?= /boot/overlays

ifeq ($(DTC),)
$(error dtc not found in PATH; install device-tree-compiler or set DTC=/path/to/dtc)
endif

export DTC
export KERNEL_SRC
export OVERLAY_INSTALL_DIR

all: 
	$(MAKE) -C alvium-csi2-driver 

install: 
	$(MAKE) -C alvium-csi2-driver install
	@echo "  DEPMOD all"
	@depmod -a
