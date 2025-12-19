
KERNEL_SRC ?= /lib/modules/$(shell uname -r)/build
DTC ?= dtc
OVERLAY_INSTALL_DIR ?= /boot/overlays

export DTC
export KERNEL_SRC
export OVERLAY_INSTALL_DIR

all: 
	$(MAKE) -C alvium-csi2-driver 

install: 
	$(MAKE) -C alvium-csi2-driver install
	@echo "  DEPMOD all"
	@depmod -a
