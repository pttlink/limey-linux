#############################################################
#
# inadyn DDNS client
#
#############################################################
# Copyright (C) 2001-2005 by Erik Andersen <andersen@codepoet.org>
# Copyright (C) 2005 by Steve Rodgers <hwstar@rodgers.sdcoxmail.com>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU Library General Public License as
# published by the Free Software Foundation; either version 2 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# Library General Public License for more details.
#
# You should have received a copy of the GNU Library General Public
# License along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307
# USA
INADYN_VERS=1.96
INADYN_SOURCE:=inadyn_$(INADYN_VERS).orig.tar.gz
INADYN_SITE:=http://ftp.debian.org/pool/main/i/inadyn
INADYN_DIR:=$(BUILD_DIR)/inadyn-$(INADYN_VERS)

inadyn: $(TARGET_DIR)/sbin/inadyn

$(DL_DIR)/$(INADYN_SOURCE):
	$(WGET) -P $(DL_DIR) $(INADYN_SITE)/$(INADYN_SOURCE)

inadyn-source: $(DL_DIR)/$(INADYN_SOURCE)

$(INADYN_DIR)/.unpacked: $(DL_DIR)/$(INADYN_SOURCE)
	zcat $(DL_DIR)/$(INADYN_SOURCE) | tar -C $(BUILD_DIR) $(TAR_OPTIONS) -
	touch $(INADYN_DIR)/.unpacked

$(INADYN_DIR)/inadyn: $(INADYN_DIR)/.unpacked
	$(MAKE) CC="$(TARGET_CC)" PREFIX=\"\" -C $(INADYN_DIR)

$(TARGET_DIR)/sbin/inadyn: $(INADYN_DIR)/inadyn
	$(INSTALL) -m 0770 -D $(INADYN_DIR)/bin/linux/inadyn $(TARGET_DIR)/sbin

inadyn-clean:
	rm -f $(TARGET_DIR)/sbin/inadyn
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
