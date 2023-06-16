#!/bin/bash
#
# By Huson
# 2023-06-16
#
INSET_FILES_DIR=$1
GET_ARCH=$2

# Fix bios boot partition is under 1 MiB
echo ">> Fix bios boot partition is under 1 MiB"
sed -i 's/256/1024/g' target/linux/x86/image/Makefile

# 修改 root 密码
echo ">> Set root password"
sed -i 's/root:::0:99999:7:::/root:$1$PaaZ9jjP$tvTgcLR4tQtpbDV2cTmkB0::0:99999:7:::/g' package/base-files/files/etc/shadow


# 修改 IP 及时区
echo ">> Modify IP/hostname/timezone"
sed -i 's/192.168./10.10./g' package/base-files/files/bin/config_generate
sed -i "s/hostname='OpenWrt'/hostname='HusonRouter'\n		set system.\@system\[-1\].zonename='Asia\/Shanghai'/g" package/base-files/files/bin/config_generate
sed -i "s/timezone='UTC'/timezone='CST-8'/g" package/base-files/files/bin/config_generate

# 建立相关文件夹
echo ">> Create directory"
mkdir -p files/root files/www files/etc/subconverter/rules files/etc/openclash/core files/usr/share/v2ray files/usr/share/passwall files/usr/share/passwall2

# 植入初始化脚本
echo ">> Inset initialization script"
#curl -SsL --connect-timeout 30 -m 60 --speed-time 30 --speed-limit 1 --retry 2 https://raw.githubusercontent.com/0x01-0xff/OP_Files/master/set_op.sh -o files/root/set_op.sh 2>&1
cp $INSET_FILES_DIR/set_op.sh files/root/set_op.sh

# 植入 Passwall 规则
echo ">> Modify passwall rules"
#curl -SsL --connect-timeout 30 -m 60 --speed-time 30 --speed-limit 1 --retry 2 https://raw.githubusercontent.com/0x01-0xff/OP_Files/master/passwall_0_default_config -o files/usr/share/passwall/0_default_config 2>&1
#curl -SsL --connect-timeout 30 -m 60 --speed-time 30 --speed-limit 1 --retry 2 https://raw.githubusercontent.com/0x01-0xff/OP_Files/master/passwall2_0_default_config -o files/usr/share/passwall2/0_default_config 2>&1
cp $INSET_FILES_DIR/passwall_0_default_config files/usr/share/passwall/0_default_config
cp $INSET_FILES_DIR/passwall2_0_default_config files/usr/share/passwall2/0_default_config

# 植入 geosite_extra.dat geoip_extra.dat
echo ">> Inset geosite.dat/geoip.dat"
curl -SsL --connect-timeout 30 -m 60 --speed-time 30 --speed-limit 1 --retry 2 https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat -o files/usr/share/v2ray/geosite_extra.dat 2>&1
curl -SsL --connect-timeout 30 -m 60 --speed-time 30 --speed-limit 1 --retry 2 https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat -o files/usr/share/v2ray/geoip_extra.dat 2>&1

# 植入 OpenClash 规则
echo ">> Modify openclash rules"
#curl -SsL --connect-timeout 30 -m 60 --speed-time 30 --speed-limit 1 --retry 2 https://raw.githubusercontent.com/0x01-0xff/OP_Files/master/openclash_config_h.ini -o files/www/openclash_config_h.ini 2>&1
#curl -SsL --connect-timeout 30 -m 60 --speed-time 30 --speed-limit 1 --retry 2 https://raw.githubusercontent.com/0x01-0xff/OP_Files/master/GoogleALL.list -o files/etc/subconverter/rules/GoogleALL.list 2>&1
#curl -SsL --connect-timeout 30 -m 60 --speed-time 30 --speed-limit 1 --retry 2 https://raw.githubusercontent.com/0x01-0xff/OP_Files/master/OpenAi.list -o files/etc/subconverter/rules/OpenAi.list 2>&1
#curl -SsL --connect-timeout 30 -m 60 --speed-time 30 --speed-limit 1 --retry 2 https://raw.githubusercontent.com/0x01-0xff/OP_Files/master/PayPal.list -o files/etc/subconverter/rules/PayPal.list 2>&1
cp $INSET_FILES_DIR/openclash_config_h.ini files/www/openclash_config_h.ini
cp $INSET_FILES_DIR/GoogleALL.list files/etc/subconverter/rules/GoogleALL.list
cp $INSET_FILES_DIR/OpenAi.list files/etc/subconverter/rules/OpenAi.list
cp $INSET_FILES_DIR/PayPal.list files/etc/subconverter/rules/PayPal.list
sed -i '2i Huson规则,config_h.ini,http:\/\/127.0.0.1\/openclash_config_h.ini\nHuson远程规则,remote_config_h.ini,https:\/\/raw.githubusercontent.com\/0x01-0xff\/ProxyProfiles\/master\/Clash\/remote_config_h.ini' feeds/openclash/luci-app-openclash/root/usr/share/openclash/res/sub_ini.list

# 植入 OpenClash Core
echo ">> Inset openclash core"
curl -SsL --connect-timeout 30 -m 60 --speed-time 30 --speed-limit 1 --retry 2 https://raw.githubusercontent.com/vernesong/OpenClash/core/master/core_version -o files/etc/openclash/core/clash_last_version 2>&1
tmp_TUN_CORE_VERSION=$(sed -n 2p files/etc/openclash/core/clash_last_version 2>/dev/null)
rm -rf files/etc/openclash/core/clash_last_version >/dev/null 2>&1
curl -SsL --connect-timeout 30 -m 60 --speed-time 30 --speed-limit 1 --retry 2 https://raw.githubusercontent.com/vernesong/OpenClash/core/master/premium/clash-linux-$GET_ARCH-"$tmp_TUN_CORE_VERSION".gz -o files/etc/openclash/core/clash-tun-linux-$GET_ARCH.gz 2>&1
#gzip -t files/etc/openclash/core/clash-tun-linux-$GET_ARCH.gz >/dev/null 2>&1
gzip -d files/etc/openclash/core/clash-tun-linux-$GET_ARCH.gz >/dev/null 2>&1
mv files/etc/openclash/core/clash-tun-linux-$GET_ARCH files/etc/openclash/core/clash_tun >/dev/null 2>&1
rm -rf files/etc/openclash/core/clash-tun-linux-$GET_ARCH.gz >/dev/null 2>&1
[ -e files/etc/openclash/core/clash_tun ] && echo "clash_tun done."
curl -SsL --connect-timeout 30 -m 60 --speed-time 30 --speed-limit 1 --retry 2 https://raw.githubusercontent.com/vernesong/OpenClash/core/master/meta/clash-linux-$GET_ARCH.tar.gz -o files/etc/openclash/core/clash-meta-linux-$GET_ARCH.tar.gz 2>&1
#gzip -t files/etc/openclash/core/clash-meta-linux-$GET_ARCH.tar.gz >/dev/null 2>&1
tar zxvf files/etc/openclash/core/clash-meta-linux-$GET_ARCH.tar.gz -C files/etc/openclash/core >/dev/null 2>&1
mv files/etc/openclash/core/clash files/etc/openclash/core/clash_meta >/dev/null 2>&1
rm -rf files/etc/openclash/core/clash-meta-linux-$GET_ARCH.tar.gz >/dev/null 2>&1
[ -e files/etc/openclash/core/clash_meta ] && echo "clash_meta done."
curl -SsL --connect-timeout 30 -m 60 --speed-time 30 --speed-limit 1 --retry 2 https://raw.githubusercontent.com/vernesong/OpenClash/core/master/dev/clash-linux-$GET_ARCH.tar.gz -o files/etc/openclash/core/clash-linux-$GET_ARCH.tar.gz 2>&1
#gzip -t files/etc/openclash/core/clash-linux-$GET_ARCH.tar.gz >/dev/null 2>&1
tar zxvf files/etc/openclash/core/clash-linux-$GET_ARCH.tar.gz -C files/etc/openclash/core >/dev/null 2>&1
rm -rf files/etc/openclash/core/clash-linux-$GET_ARCH.tar.gz >/dev/null 2>&1
[ -e files/etc/openclash/core/clash ] && echo "clash done."

# 文件权限设置
echo ">> Set permissions"
rm -rf $INSET_FILES_DIR >/dev/null 2>&1
chmod -R 4755 files
chmod 664 files/usr/share/passwall/0_default_config
chmod 664 files/usr/share/passwall2/0_default_config
