#############################################################
#
# inadyn DDNS client
#
#############################################################

INADYN_VERSION=1.96.2
INADYN_SOURCE:=inadyn_$(INADYN_VERSION).orig.tar.gz
INADYN_SITE:=http://ftp.debian.org/pool/main/i/inadyn
INADYN_DIR:=$(BUILD_DIR)/inadyn-$(INADYN_VERSION)
INADYN_BINARY:=bin/linux/inadyn
INADYN_TARGET_BINARY:=sbin/inadyn


$(DL_DIR)/$(INADYN_SOURCE):
	$(call DOWNLOAD,$(INADYN_SITE),$(INADYN_SOURCE)) 

$(INADYN_DIR)/.source: $(DL_DIR)/$(INADYN_SOURCE)
	$(ZCAT) $(DL_DIR)/$(INADYN_SOURCE) | tar -C $(BUILD_DIR) $(TAR_OPTIONS) -
	touch $@

$(INADYN_DIR)/.patched: $(INADYN_DIR)/.source
	patch -d $(INADYN_DIR) -p0 < package/inadyn/inadyn.patch
	touch $@

$(INADYN_DIR)/$(INADYN_BINARY): $(INADYN_DIR)/.patched
	$(MAKE) CC="$(TARGET_CC)" PREFIX=\"\" -C $(INADYN_DIR)

$(TARGET_DIR)/$(INADYN_TARGET_BINARY): $(INADYN_DIR)/$(INADYN_BINARY)
	$(INSTALL) -m 0770 -D $(INADYN_DIR)/$(INADYN_BINARY) $(TARGET_DIR)/$(INADYN_TARGET_BINARY)

inadyn: uclibc $(TARGET_DIR)/$(INADYN_TARGET_BINARY)

inadyn-source:	$(DL_DIR)/$(INADYN_SOURCE)
	
inadyn-clean:
	-rm -f $(TARGET_DIR)/$(INADYN_TARGET_BINARY)
	-$(MAKE) -C $(INADYN_DIR) clean

inadyn-dirclean:
	rm -rf $(INADYN_DIR)

#############################################################
#
# Toplevel Makefile options
#
#############################################################

ifeq ($(strip $(BR2_PACKAGE_INADYN)),y)
TARGETS+=inadyn
endif
