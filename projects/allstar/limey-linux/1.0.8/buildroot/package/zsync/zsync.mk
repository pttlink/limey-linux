#############################################################
#
# zsync
#
#############################################################

ZSYNC_VERSION = 0.6.1
ZSYNC_SOURCE = zsync-$(ZSYNC_VERSION).tar.bz2
ZSYNC_SITE = http://zsync.moria.org.uk/download
ZSYNC_DIR:=$(BUILD_DIR)/zsync-$(ZSYNC_VERSION)
ZSYNC_BINARY:=zsync
ZSYNC_TARGET_BINARY:=bin/zsync

$(DL_DIR)/$(ZSYNC_SOURCE):
	$(call DOWNLOAD,$(ZSYNC_SITE),$(ZSYNC_SOURCE))

$(ZSYNC_DIR)/.source: $(DL_DIR)/$(ZSYNC_SOURCE)
	$(BZCAT) $(DL_DIR)/$(ZSYNC_SOURCE) | tar -C $(BUILD_DIR) $(TAR_OPTIONS) -
	touch $@

$(ZSYNC_DIR)/.configured: $(ZSYNC_DIR)/.source
	(cd $(ZSYNC_DIR); rm -rf config.cache; \
	$(TARGET_CONFIGURE_OPTS) \
	$(TARGET_CONFIGURE_ARGS) \
	./configure \
	--target=$(GNU_TARGET_NAME) \
	--host=$(GNU_TARGET_NAME) \
	--build=$(GNU_HOST_NAME) \
	--prefix=/usr \
	--sysconfdir=/etc \
	)
	touch $@

$(ZSYNC_DIR)/$(ZSYNC_BINARY): $(ZSYNC_DIR)/.configured
	$(MAKE) CC=$(TARGET_CC) -C $(ZSYNC_DIR)

$(TARGET_DIR)/$(ZSYNC_TARGET_BINARY): $(ZSYNC_DIR)/$(ZSYNC_BINARY)
	cp  $(ZSYNC_DIR)/$(ZSYNC_BINARY) $(TARGET_DIR)/$(ZSYNC_TARGET_BINARY)

zsync: uclibc $(TARGET_DIR)/$(ZSYNC_TARGET_BINARY)

zsync-source: $(DL_DIR)/$(ZSYNC_SOURCE)

zsync-clean:
	-$(MAKE) -C $(ZSYNC_DIR) clean

zsync-dirclean:
	rm -rf $(ZSYNC_DIR)

ifeq ($(BR2_PACKAGE_ZSYNC),y)
TARGETS+=zsync
endif

