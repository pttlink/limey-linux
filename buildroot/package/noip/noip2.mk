#############################################################
#
# noip DDNS client
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

NOIP_SOURCE:=noip-duc-linux.tar.gz
NOIP_VERS:=2.1.9-1
NOIP_SITE:=http://limeylinux.org/downloads/source-tarballs
NOIP_DIR:=$(BUILD_DIR)/noip-$(NOIP_VERS)

noip: $(TARGET_DIR)/sbin/noip2

$(DL_DIR)/$(NOIP_SOURCE):
	$(WGET) -P $(DL_DIR) $(NOIP_SITE)/$(NOIP_SOURCE)

noip-source: $(DL_DIR)/$(NOIP_SOURCE)

$(NOIP_DIR)/.unpacked: $(DL_DIR)/$(NOIP_SOURCE)
	zcat $(DL_DIR)/$(NOIP_SOURCE) | tar -C $(BUILD_DIR) $(TAR_OPTIONS) -
	touch $(NOIP_DIR)/.unpacked

$(NOIP_DIR)/noip2: $(NOIP_DIR)/.unpacked
	$(MAKE) CC="$(TARGET_CC)" PREFIX=\"\" -C $(NOIP_DIR)

$(TARGET_DIR)/sbin/noip2: $(NOIP_DIR)/noip2
	cp $(NOIP_DIR)/noip2 $(TARGET_DIR)/sbin/noip2

noip-clean:
	rm -f $(TARGET_DIR)/sbin/noip
	-$(MAKE) -C $(NOIP_DIR) clean

noip-dirclean:
	rm -rf $(NOIP_DIR)
#############################################################
#
# Toplevel Makefile options
#
#############################################################
ifeq ($(strip $(BR2_PACKAGE_NOIP)),y)
TARGETS+=noip
endif
