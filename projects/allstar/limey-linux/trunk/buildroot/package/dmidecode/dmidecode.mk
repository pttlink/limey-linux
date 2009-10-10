#############################################################
#
# dmidecode
#
#############################################################

DMIDECODE_VERSION = 2.10
DMIDECODE_SOURCE = dmidecode-$(DMIDECODE_VERSION).tar.gz
DMIDECODE_SITE = http://savannah.inetbridge.net/dmidecode/
DMIDECODE_DIR:=$(BUILD_DIR)/dmidecode-$(DMIDECODE_VERSION)
DMIDECODE_BINARY:=dmidecode
DMIDECODE_TARGET_BINARY:=usr/bin/dmidecode

$(DL_DIR)/$(DMIDECODE_SOURCE):
	$(call DOWNLOAD,$(DMIDECODE_SITE),$(DMIDECODE_SOURCE))

$(DMIDECODE_DIR)/.source: $(DL_DIR)/$(DMIDECODE_SOURCE)
	$(ZCAT) $(DL_DIR)/$(DMIDECODE_SOURCE) | tar -C $(BUILD_DIR) $(TAR_OPTIONS) -
	touch $@

$(DMIDECODE_DIR)/.configured: $(DMIDECODE_DIR)/.source
	touch $@

$(DMIDECODE_DIR)/$(DMIDECODE_BINARY): $(DMIDECODE_DIR)/.configured
	$(MAKE) CC=$(TARGET_CC) -C $(DMIDECODE_DIR)

$(TARGET_DIR)/$(DMIDECODE_TARGET_BINARY): $(DMIDECODE_DIR)/$(DMIDECODE_BINARY)
	cp  $(DMIDECODE_DIR)/$(DMIDECODE_BINARY) $(TARGET_DIR)/$(DMIDECODE_TARGET_BINARY)

dmidecode: uclibc $(TARGET_DIR)/$(DMIDECODE_TARGET_BINARY)

dmidecode-source: $(DL_DIR)/$(DMIDECODE_SOURCE)

dmidecode-clean:
	-$(MAKE) -C $(DMIDECODE_DIR) clean

dmidecode-dirclean:
	rm -rf $(DMIDECODE_DIR)

ifeq ($(BR2_PACKAGE_DMIDECODE),y)
TARGETS+=dmidecode
endif

