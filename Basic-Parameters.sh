#!/bin/bash
#
# By Huson
# 2023-07-06 11:51
#
# System Basic Parameters
#

# Fix bios boot partition is under 1 MiB
echo ">> Fix bios boot partition is under 1 MiB"
sed -i 's/256/1024/g' target/linux/x86/image/Makefile

# Inset root password
#echo ">> Set root password"
#sed -i 's/root:::0:99999:7:::/root:\$1\$PaaZ9jjP\$tvTgcLR4tQtpbDV2cTmkB0::0:99999:7:::/g' package/base-files/files/etc/shadow

# Modify IP/hostname/timezone
echo ">> Modify IP/hostname/timezone"
sed -i 's/192.168./10.10./g' package/base-files/files/bin/config_generate
sed -i "s/hostname='OpenWrt'/hostname='HusonRouter'\n		set system.\@system\[-1\].zonename='Asia\/Shanghai'/g" package/base-files/files/bin/config_generate
sed -i "s/timezone='UTC'/timezone='CST-8'/g" package/base-files/files/bin/config_generate
