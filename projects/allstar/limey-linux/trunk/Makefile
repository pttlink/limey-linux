#
# Makefile for limey linux
#
CFDEVICE?=/dev/sdg	# Important! Change this to your raw cf device node
MOBO?=VIA		# for VIA Mini-itx M6000, ME6000, SP8000, or CN10000
#MOBO?=D201GLY2		# for Intel/Jetway D201GLY-2 motherboard
#MOBO=D945GCLF		# for Intel Atom D945GCLF
#MOBO=i3368g		# for iGologic i3386-LF motherboard

# Do not mess with anything down here unless you know what you are doing!

VERSION:=1.0.7			# Limey linux version
KERNELVERSION:=2.6.27.9		# Linux Kernel version
BUILDDIR:=$(shell /bin/pwd)	# absolute path to build directory

LLVERS:=$(strip $(VERSION))
KVERS:=$(strip $(KERNELVERSION))
TOPDIR:=$(strip $(BUILDDIR))
MB:=$(strip $(MOBO))

ifeq "$(MB)" "VIA"
LINUX_ARCH:=i386
PROCESSOR:=i586
KERNEL_CONFIG_FILE:=via-kernel.config
BUILDROOT_CONFIG_FILE:=i586-buildroot.config
UCLIBC_CONFIG_FILE:=i586-uclibc.config
else
ifeq "$(MB)" "D201GLY2"
LINUX_ARCH:=i386
PROCESSOR:=i686
KERNEL_CONFIG_FILE:=d201gly2-kernel.config
BUILDROOT_CONFIG_FILE:=i686-buildroot.config
UCLIBC_CONFIG_FILE:=i686-uclibc.config
else
ifeq "$(MB)" "D945GCLF"
LINUX_ARCH:=i386
PROCESSOR:=i686
KERNEL_CONFIG_FILE:=d945gclf-kernel.config
BUILDROOT_CONFIG_FILE:=i686-buildroot.config
UCLIBC_CONFIG_FILE:=i686-uclibc.config
else
ifeq "$(MB)" "i3368g"
LINUX_ARCH:=i386
PROCESSOR:=i686
KERNEL_CONFIG_FILE:=i3368g-kernel.config
BUILDROOT_CONFIG_FILE:=i686-buildroot.config
UCLIBC_CONFIG_FILE:=i686-uclibc.config
else
$(error "Unknown or unspecified motherboard: $(MOBO)")
endif
endif
endif
endif

export PROCESSOR
export KVERS
export MOBO
export LLVERS

LINUX_VERSION:=linux-$(KVERS)
LINUX_PACKAGE:=$(strip $(LINUX_VERSION)).tar.bz2
LINUX_SITE:=http://www.kernel.org/pub/linux/kernel/v2.6/$(LINUX_PACKAGE)
LINUX_CROSS_COMPILE:=$(strip $(TOPDIR))/buildroot/build_$(PROCESSOR)/staging_dir/bin/$(PROCESSOR)-linux-

SYSLINUX_VERSION:=syslinux-2.10
SYSLINUX_PACKAGE:=$(SYSLINUX_VERSION).tar.bz2
SYSLINUX_SITE:=http://www.kernel.org/pub/linux/utils/boot/syslinux/Old/$(SYSLINUX_PACKAGE)

.PHONY: allbins

allbins:	prist_root_fs_$(PROCESSOR) kernel.bzi buildstate/linux_kdev 


buildstate/buildroot_configured:
	-mkdir -p buildstate
	-mkdir -p buildroot/dl
	-cp ../repo/* buildroot/dl #copy source tarballs from repo if they are there	
	cp configs/$(BUILDROOT_CONFIG_FILE) buildroot/.config
	cp configs/$(UCLIBC_CONFIG_FILE) buildroot/toolchain/uClibc/uClibc.config
	cp configs/busybox.config buildroot/package/busybox/busybox.config
	cp -f configs/device_table.txt buildroot/target/generic 
	make -C buildroot oldconfig
	touch buildstate/buildroot_configured

buildroot/rootfs.$(PROCESSOR).ext2: buildstate/buildroot_configured
	make -C buildroot 

prist_root_fs_$(PROCESSOR):	buildroot/rootfs.$(PROCESSOR).ext2
	cp buildroot/rootfs.$(PROCESSOR).ext2 prist_root_fs_$(PROCESSOR)

buildstate/linux_downloaded:
	-rm linux buildstate/linux_downloaded
	-mkdir -p buildstate
	-mkdir -p dl
	-cp ../repo/$(LINUX_PACKAGE) dl 
	if ! [ -f dl/$(LINUX_PACKAGE) ]; \
	then \
	(cd dl; wget $(LINUX_SITE)); \
	fi
	touch buildstate/linux_downloaded

buildstate/linux_unpacked:	buildstate/linux_downloaded
	tar xjf dl/$(LINUX_PACKAGE)
	touch buildstate/linux_unpacked
	ln -s $(LINUX_VERSION) linux

buildstate/linux_patched: buildstate/linux_unpacked
	touch buildstate/linux_patched	


buildstate/syslinux_downloaded:
	-mkdir -p buildstate
	-rm syslinux buildstate/syslinux_downloaded
	-mkdir -p dl
	-cp ../repo/$(SYSLINUX_PACKAGE) dl 
	if ! [ -f dl/$(SYSLINUX_PACKAGE) ]; \
	then \
	(cd dl; wget $(SYSLINUX_SITE)); \
	fi
	touch buildstate/syslinux_downloaded

buildstate/syslinux_unpacked: buildstate/syslinux_downloaded
	tar xjf dl/$(SYSLINUX_PACKAGE)
	ln -s $(SYSLINUX_VERSION) syslinux
	touch buildstate/syslinux_unpacked

buildstate/linux_configured:	buildstate/linux_patched
	make -C linux mrproper ARCH=$(LINUX_ARCH)
	cp configs/$(KERNEL_CONFIG_FILE) linux/.config
	make -C linux oldconfig ARCH=$(LINUX_ARCH)
	touch buildstate/linux_configured

buildstate/linux_built: buildstate/linux_configured
	echo $(LINUX_CROSS_COMPILE)
	make CROSS_COMPILE="$(LINUX_CROSS_COMPILE)" -C linux bzImage ARCH=$(LINUX_ARCH)
	make CROSS_COMPILE="$(LINUX_CROSS_COMPILE)" -C linux modules ARCH=$(LINUX_ARCH)
	touch buildstate/linux_built


# Build a partial 2.6 kernel tree with module building tools and include files

buildstate/linux_kdev:	buildstate/linux_built
	-rm -rf kdev
	mkdir -p kdev
	-cp -a linux/. kdev
	(cd kdev; rm -rf net/* fs/* kernel/* ipc/* usr/* sound/* crypto/* Documentation drivers/* int/* mm/* lib/*)
	(cd kdev/include; rm -rf asm-alpha asm-arm asm-arm26 asm-cris \
        asm-frv asm-h8300 asm-ia64 asm_m32r asm-m68k asm-m68knommu asm-m32r asm-mips asm-mips64 \
	asm-parisc asm-ppc asm-ppc64 asm-s390 asm-s390x \
        asm-sh asm-sh64 asm-sparc asm-sparc64 asm-x86_64 asm-um asm-v850)
	(cd kdev/arch; rm -rf alpha arm arm26 cris frv h8300 ia64 m32r m68k m68knommu \
         mips parisc ppc ppc64 s390 sh sh64 sparc sparc64 um v850 x86_64)
	(cd kdev/scripts/basic; $(LINUX_CROSS_COMPILE)gcc fixdep.c -o fixdep) # Recompile with target gcc
	(cd kdev/scripts/mod; $(LINUX_CROSS_COMPILE)gcc modpost.c file2alias.c sumversion.c -o modpost) # Recompile with target gcc
	(cd kdev; tar cfz ../kdev.tgz .)
	touch buildstate/linux_kdev

buildstate/syslinux_built:buildstate/syslinux_unpacked
	make -C syslinux syslinux
	touch buildstate/syslinux_built

kernel.bzi:	prist_root_fs_$(PROCESSOR) buildstate/linux_built
	-rm kernel.bzi
	ln -s linux/arch/i386/boot/bzImage kernel.bzi

ramdisk.img: prist_root_fs_$(PROCESSOR)
	sudo -E ./mkramdisk

.PHONY:	cf cfimg clean distclean kerneldistclean syslinuxdistclean buildrootdistclean archive setup 


cf:	ramdisk.img kernel.bzi buildstate/syslinux_built buildstate/linux_kdev
	(export CFDEVICE=$(CFDEVICE); sudo -E ./mkcf)

cfzero:
	(sudo dd if=/dev/zero of=$(CFDEVICE))

cfimg:
	(sudo dd if=$(CFDEVICE) of=cfimg-$(LLVERS))
	tar cfz ../cfimg-$(LLVERS).tar.gz cfimg-$(LLVERS)
	rm -f cfimg-$(LLVERS)
clean:	
	-rm buildstate/linux_built
	-rm buildstate/syslinux_built
	make -C syslinux clean
	make -C linux mrproper
	make -C buildroot clean
	-rm -rf buildroot/build_$(PROCESSOR)/*
	
kerneldistclean:
	-rm buildstate/linux_*
	-rm kernel.bzi
	-rm -rf linux*

syslinuxdistclean:
	-rm buildstate/syslinux_*
	-rm -rf syslinux syslinux-2.*

buildrootdistclean:
	make -C buildroot distclean
	-rm -rf buildroot/build_$(PROCESSOR)
	-rm -rf buildroot/toolchain_build_$(PROCESSOR)
	-rm -rf buildroot/dl/*
	-rm -f buildroot/rootfs.$(PROCESSOR).ext2
	-rm buildstate/buildroot_configured

distclean:	kerneldistclean syslinuxdistclean buildrootdistclean
	-rm prist_root_fs_$(PROCESSOR)
	-rm -f root_fs_$(PROCESSOR)
	-rm -rf dl
	-rm -rf kdev
	-rm -rf kdev.tgz
	-rm -rf syscfg
	-rm -rf *.img
	-rm -rf buildstate
	-rm -rf buildroot/.c*
	-rm buildroot/toolchain/uClibc/uClibc.config
	-rm buildroot/toolchain/uClibc.config


archive:	distclean
	tar czf ../ll-vers-$(LLVERS).tar.gz *

setup:	buildstate/syslinux_built	
	mkdir -p syscfg
	(cd syscfg; tar xzf ../syscfg.tgz)
	touch buildstate/syscfg_unpacked;
