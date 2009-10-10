#############################################################
#
# grep
#
#############################################################
GNUGREP_VERSION:=2.5.3
GNUGREP_SOURCE:=grep-$(GNUGREP_VERSION).tar.gz
GNUGREP_SITE:=http://mirrors.kernel.org/gnu/grep

GNUGREP_DIR:=$(BUILD_DIR)/grep-$(GNUGREP_VERSION)
GNUGREP_CAT:=$(ZCAT)
GNUGREP_BINARY:=src/grep
GNUGREP_TARGET_BINARY:=bin/grep

$(DL_DIR)/$(GNUGREP_SOURCE):
	$(call DOWNLOAD,$(GNUGREP_SITE),$(GNUGREP_SOURCE))

$(GNUGREP_DIR)/.source: $(DL_DIR)/$(GNUGREP_SOURCE)
	$(ZCAT) $(DL_DIR)/$(GNUGREP_SOURCE) | tar -C $(BUILD_DIR) $(TAR_OPTIONS) -
	touch $@

$(GNUGREP_DIR)/.configured: $(GNUGREP_DIR)/.source
	(cd $(GNUGREP_DIR); rm -rf config.cache; \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS)" \
		./configure \
		--target=$(GNU_TARGET_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--build=$(GNU_HOST_NAME) \
		--prefix=/usr \
		--exec-prefix=/usr \
		--bindir=/usr/bin \
		--sbindir=/usr/sbin \
		--libdir=/lib \
		--libexecdir=/usr/lib \
		--sysconfdir=/etc \
		--datadir=/usr/share \
		--localstatedir=/var \
		--mandir=/usr/man \
		--infodir=/usr/info \
		$(DISABLE_NLS) \
		$(DISABLE_LARGEFILE) \
		--disable-perl-regexp \
		--without-included-regex \
	);
	touch $@

$(GNUGREP_DIR)/$(GNUGREP_BINARY): $(GNUGREP_DIR)/.configured
	$(MAKE) -C $(GNUGREP_DIR)

# This stuff is needed to work around GNU make deficiencies
grep-target_binary: $(GNUGREP_DIR)/$(GNUGREP_BINARY)
	@if [ -L $(TARGET_DIR)/$(GNUGREP_TARGET_BINARY) ] ; then \
		rm -f $(TARGET_DIR)/$(GNUGREP_TARGET_BINARY); fi;
	set -x; \
	rm -f $(TARGET_DIR)/bin/grep $(TARGET_DIR)/bin/egrep $(TARGET_DIR)/bin/fgrep; \
	cp -a $(GNUGREP_DIR)/src/grep $(GNUGREP_DIR)/src/egrep \
	$(GNUGREP_DIR)/src/fgrep $(TARGET_DIR)/bin/;

grep: uclibc grep-target_binary

grep-source:	$(DL_DIR)/$(GNUGREP_SOURCE)

grep-clean:
	$(MAKE) DESTDIR=$(TARGET_DIR) -C $(GNUGREP_DIR) uninstall
	-$(MAKE) -C $(GNUGREP_DIR) clean

grep-dirclean:
	rm -rf $(GNUGREP_DIR)

#############################################################
#
# Toplevel Makefile options
#
#############################################################
ifeq ($(strip $(BR2_PACKAGE_GREP)),y)
TARGETS+=grep
endif

