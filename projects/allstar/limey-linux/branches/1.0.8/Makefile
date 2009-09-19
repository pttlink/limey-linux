#
# Makefile for limey linux
#

# Place to store our source tarballs so that they don't have to be downloaded from the Internet between make distcleans
DLSAVE?=../dlsave
# Important! Change this to your raw cf device node
CFDEVICE?=/dev/sdg
# for Non-DMI Capable VIA Mini-itx M6000, ME6000, SP8000, or CN10000
#MOBO?=NONDMI-586
# for DMI-Capable Intel D201GLY2, D945GCLF, or Igoe Logic I3386g
MOBO?=DMI-686

# Do not mess with anything down here unless you know what you are doing!

VERSION:=1.0.8			# Limey linux version
KERNELVERSION:=2.6.30.5		# Linux Kernel version
BUILDDIR:=$(shell /bin/pwd)	# absolute path to build directory

LLVERS:=$(strip $(VERSION))
KVERS:=$(strip $(KERNELVERSION))
TOPDIR:=$(strip $(BUILDDIR))
MB:=$(strip $(MOBO))

ifeq "$(MB)" "NONDMI-586"
LINUX_ARCH:=i386
PROCESSOR:=i586
KERNEL_CONFIG_FILE:=i586-kernel-generic.config
BUILDROOT_CONFIG_FILE:=i586-buildroot.config
UCLIBC_CONFIG_FILE:=i586-uclibc.config
else
ifeq "$(MB)" "DMI-686"
LINUX_ARCH:=i386
PROCESSOR:=i686
KERNEL_CONFIG_FILE:=i686-kernel-generic.config
BUILDROOT_CONFIG_FILE:=i686-buildroot.config
UCLIBC_CONFIG_FILE:=i686-uclibc.config
else
$(error "Unknown or unspecified motherboard: $(MOBO)")
endif
endif

export PROCESSOR
export KVERS
export MOBO
export LLVERS

LINUX_VERSION:=linux-$(KVERS)
LINUX_PACKAGE:=$(strip $(LINUX_VERSION)).tar.bz2
LINUX_SITE:=http://www.kernel.org/pub/linux/kernel/v2.6/$(LINUX_PACKAGE)
LINUX_CROSS_COMPILE:=$(strip $(TOPDIR))/buildroot/build_$(PROCESSOR)/staging_dir/usr/bin/$(PROCESSOR)-linux-

SYSLINUX_VERSION:=syslinux-3.75
SYSLINUX_PACKAGE:=$(SYSLINUX_VERSION).tar.bz2
SYSLINUX_SITE:=http://www.kernel.org/pub/linux/utils/boot/syslinux/Old/$(SYSLINUX_PACKAGE)

.PHONY: allbins cf cfimg clean distclean linuxdistclean syslinuxdistclean lc brconfig brremake buildrootdistclean archive savemods ramdisk

allbins:	buildstate/syslinux_built buildstate buildstate/buildroot_built buildstate/linux_kdev

savemods:	buildstate/linux_savemodules

buildstate/ready:	
	-mkdir -p buildstate
	-mkdir -p buildroot/dl
	if [ -d $(DLSAVE) ]; \
	then \
	(cp -l $(DLSAVE)/* buildroot/dl); \
	fi   
	-rm buildroot/.config buildroot/uClibc.config buildroot/busybox.config
	cp configs/$(BUILDROOT_CONFIG_FILE) buildroot/.config
	cp configs/$(UCLIBC_CONFIG_FILE) buildroot/uClibc.config
	cp configs/busybox.config buildroot/busybox.config
	cp configs/device_table.txt buildroot/target/generic 
	touch $@

buildstate/syslinux_downloaded: buildstate/ready
	-rm syslinux buildstate/syslinux_downloaded
	-mkdir -p dl
	if ! [ -f $(DLSAVE)/$(SYSLINUX_PACKAGE) ]; \
	then \
	(cd $(DLSAVE); wget $(SYSLINUX_SITE)); \
	fi
	touch $@

buildstate/syslinux_unpacked: buildstate/syslinux_downloaded
	tar xjf $(DLSAVE)/$(SYSLINUX_PACKAGE)
	ln -s $(SYSLINUX_VERSION) syslinux
	touch $@

buildstate/syslinux_built:buildstate/syslinux_unpacked
	make -C syslinux 
	touch $@

buildstate/buildroot_configured: buildstate/ready
	 make -C buildroot oldconfig
	touch $@

buildstate/buildroot_made: buildstate/buildroot_configured 
	make -C buildroot 
	touch $@

buildstate/buildroot_built: buildstate/buildroot_made
	cp buildroot/binaries/limey/rootfs.$(PROCESSOR).ext2 prist_root_fs_$(PROCESSOR)
	-if [ -d $(DLSAVE) ]; \
	then \
	(cp -u buildroot/dl/* $(DLSAVE)); \
	fi   
	touch $@

buildstate/linux_downloaded: buildstate/ready
	if ! [ -f $(DLSAVE)/$(LINUX_PACKAGE) ]; \
	then \
	(cd $(DLSAVE); wget $(LINUX_SITE)); \
	fi
	touch $@

buildstate/linux_unpacked:	buildstate/linux_downloaded
	tar xjf $(DLSAVE)/$(LINUX_PACKAGE)
	touch buildstate/linux_unpacked
	ln -s $(LINUX_VERSION) linux

buildstate/linux_patched: buildstate/linux_unpacked
	touch $@	

buildstate/linux_configured:    buildstate/linux_patched
	make -C linux mrproper ARCH=$(LINUX_ARCH)
	cp configs/$(KERNEL_CONFIG_FILE) linux/.config
	make -C linux oldconfig ARCH=$(LINUX_ARCH)
	touch $@

buildstate/linux_built: buildstate/linux_configured
	echo $(LINUX_CROSS_COMPILE)
	make CROSS_COMPILE="$(LINUX_CROSS_COMPILE)" -C linux bzImage ARCH=$(LINUX_ARCH)
	make CROSS_COMPILE="$(LINUX_CROSS_COMPILE)" -C linux modules ARCH=$(LINUX_ARCH)
	touch $@

buildstate/linux_savemodules: buildstate/linux_built
	make CROSS_COMPILE="$(LINUX_CROSS_COMPILE)" -C linux modules_install INSTALL_MOD_PATH=linux_modules  ARCH=$(LINUX_ARCH)
	touch $@

# Build a partial 2.6 kernel tree with module building tools and include files

buildstate/linux_kdev:	buildstate/linux_savemodules
	-rm -rf kdev
	mkdir -p kdev
	-cp -a linux/. kdev
	(cd kdev; rm -rf net/* fs/* kernel/* ipc/* usr/* sound/* crypto/* Documentation drivers/* int/* mm/* lib/*)
	(cd kdev/include; rm -rf asm-alpha asm-arm asm-arm26 asm-cris \
        asm-frv asm-h8300 asm-ia64 asm_m32r asm-m68k asm-m68knommu asm-m32r asm-mips asm-mips64 \
	asm-parisc asm-ppc asm-ppc64 asm-s390 asm-s390x \
        asm-sh asm-sh64 asm-sparc asm-sparc64 asm-x86_64 asm-um asm-v850 firmware security) 
	(cd kdev/arch; rm -rf alpha arm arm26 avr32 blackfin cris frv h8300 ia64 m32r m68k m68knommu \
         mips mn10300 parisc ppc ppc64 powerpc s390 sh sh64 sparc sparc64 um v850 x86/boot x86/kernel x86/pci x86_64 xtensa)
	(cd kdev/scripts/basic; $(LINUX_CROSS_COMPILE)gcc fixdep.c -o fixdep) # Recompile with target gcc
	(cd kdev/scripts/mod; $(LINUX_CROSS_COMPILE)gcc modpost.c file2alias.c sumversion.c -o modpost) # Recompile with target gcc
	(cd kdev; tar cfz ../kdev.tgz .)
	-rm kernel.bzi
	ln -s linux/arch/i386/boot/bzImage kernel.bzi
	touch $@


ramdisk.img: buildstate/linux_kdev buildstate/buildroot_built
	sudo -E ./mkramdisk
#
#
# phony targets
#
#

ramdisk: ramdisk.img

kernel:	buildstate/linux_kdev

brcconfig: buildstate
	-rm prist_root_fs_$(PROCESSOR) 
	-rm buildroot/binaries/limey/rootfs.$(PROCESSOR).ext2:
	-rm buildstate/buildroot_configured
	make -C buildroot menuconfig

lc: buildstate buildstate/linux_patched
	make -C linux mrproper ARCH=$(LINUX_ARCH)
	cp configs/$(KERNEL_CONFIG_FILE) linux/.config
	make -C linux menuconfig


cf:	buildstate/syslinux_built ramdisk.img buildstate/linux_kdev 
	(export CFDEVICE=$(CFDEVICE); sudo -E ./mkcf)

cfzero:
	-(sudo dd bs=1024 count=125000 if=/dev/zero of=$(CFDEVICE))
	make cf

cfimg:
	(sudo dd bs=1024 count=125000 if=$(CFDEVICE) of=cfimg-$(LLVERS))
	tar cfz ../cfimg-$(LLVERS).tar.gz cfimg-$(LLVERS)
	rm -f cfimg-$(LLVERS)
clean:	
	-rm buildstate/linux_built
	-rm buildstate/syslinux_built
	-rm buildstate/buildroot_made
	-rm buildstate/buildroot_built
	-make -C syslinux clean
	-make -C linux mrproper
	-make -C buildroot clean
	-rm -rf buildroot/build_$(PROCESSOR)/*
	
linuxdistclean:
	-rm buildstate/linux_*
	-rm kernel.bzi
	-rm ramdisk.img
	-rm -rf linux* kdev

syslinuxdistclean:
	-rm buildstate/syslinux_*
	-rm -rf syslinux syslinux-3.*


brremake:
	-rm ramdisk.img
	-rm prist_root_fs_$(PROCESSOR)
	-rm root_fs_$(PROCESSOR)
	-rm buildstate/buildroot_made
	-rm buildstate/buildroot_built
	
buildrootdistclean:
	-make -C buildroot distclean
	-rm -rf buildroot/build_$(PROCESSOR)
	-rm -rf buildroot/toolchain_build_$(PROCESSOR)
	-rm -rf buildroot/dl/*
	-rm -f buildroot/rootfs.$(PROCESSOR).ext2
	-rm buildstate/buildroot*

distclean:	linuxdistclean syslinuxdistclean buildrootdistclean
	-rm -rf buildstate
	-rm prist_root_fs_$(PROCESSOR)
	-rm -f root_fs_$(PROCESSOR)
	-rm -rf dl
	-rm -rf kdev
	-rm -rf kdev.tgz
	-rm -rf syscfg.tgz
	-rm -rf *.img
	-rm -rf buildroot/.c*
	-rm buildroot/uClibc.config
	-rm buildroot/busybox.config


archive:	distclean
	tar czf ../ll-vers-$(LLVERS).tar.gz --exclude=.svn *
