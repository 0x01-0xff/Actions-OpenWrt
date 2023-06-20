#!/bin/bash
#
# By Huson
# 2023-06-20 12:49
#
# Modify APP Config
#
INSET_FILES_DIR=$1
GET_ARCH=$2

echo ">> Create directory"
mkdir -p files/root files/etc/subconverter/rules

echo ">> Inset initialization script"
#curl -SsL --connect-timeout 30 -m 60 --speed-time 30 --speed-limit 1 --retry 2 https://raw.githubusercontent.com/0x01-0xff/OP_Files/master/set_op.sh -o files/root/set_op.sh 2>&1
cp $INSET_FILES_DIR/set_op.sh files/root/set_op.sh

echo ">> Modify passwall rules"
#curl -SsL --connect-timeout 30 -m 60 --speed-time 30 --speed-limit 1 --retry 2 https://raw.githubusercontent.com/0x01-0xff/OP_Files/master/passwall_0_default_config -o files/usr/share/passwall/0_default_config 2>&1
#curl -SsL --connect-timeout 30 -m 60 --speed-time 30 --speed-limit 1 --retry 2 https://raw.githubusercontent.com/0x01-0xff/OP_Files/master/passwall2_0_default_config -o files/usr/share/passwall2/0_default_config 2>&1
#cp $INSET_FILES_DIR/passwall_0_default_config files/usr/share/passwall/0_default_config
#cp $INSET_FILES_DIR/passwall2_0_default_config files/usr/share/passwall2/0_default_config
sed -i '/^config nodes/,$d' feeds/passwall_luci/luci-app-passwall/root/usr/share/passwall/0_default_config
sed -i '/^config nodes/,$d' feeds/passwall2/luci-app-passwall2/root/usr/share/passwall2/0_default_config
cat $INSET_FILES_DIR/pw_xray_config >> feeds/passwall_luci/luci-app-passwall/root/usr/share/passwall/0_default_config
cat $INSET_FILES_DIR/pw_xray_config >> feeds/passwall2/luci-app-passwall2/root/usr/share/passwall2/0_default_config

echo ">> Inset extra geosite.dat/geoip.dat to passwall"
mkdir -p feeds/passwall_luci/luci-app-passwall/root/usr/share/passwall/v2ray
curl -SsL --connect-timeout 30 -m 60 --speed-time 30 --speed-limit 1 --retry 2 https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat -o feeds/passwall_luci/luci-app-passwall/root/usr/share/passwall/v2ray/geosite_extra.dat 2>&1
curl -SsL --connect-timeout 30 -m 60 --speed-time 30 --speed-limit 1 --retry 2 https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat -o feeds/passwall_luci/luci-app-passwall/root/usr/share/passwall/v2ray/geoip_extra.dat 2>&1

echo ">> Inset openclash rules and convert server"
h_SUB_SERVER=$(grep -B1 '^o:value("https:\/\/api.dler.io\/sub"' feeds/openclash/luci-app-openclash/luasrc/model/cbi/openclash/config-subscribe-edit.lua | sed -n 1p 2>/dev/null)
h_SUB_SERVER=${h_SUB_SERVER: 17: 9}
if [ ! "$h_SUB_SERVER" == "127.0.0.1" ]; then
    sed -i 's/o:value("https:\/\/api.dler.io\/sub"/o:value("https:\/\/127.0.0.1:25500\/sub", translate("127.0.0.1")..translate("(Router Side Service)"))\no:value("https:\/\/api.dler.io\/sub"/g' feeds/openclash/luci-app-openclash/luasrc/model/cbi/openclash/config-subscribe-edit.lua
    sed -i 's/o.default = "https:\/\/api.dler.io\/sub"/o.default = "https:\/\/127.0.0.1:25500\/sub"/g' feeds/openclash/luci-app-openclash/luasrc/model/cbi/openclash/config-subscribe-edit.lua
fi
h_RULES_CON=$(sed -n 2p feeds/openclash/luci-app-openclash/root/usr/share/openclash/res/sub_ini.list 2>/dev/null)
[ ! "${h_RULES_CON: 0: 5}" == "Huson" ] && sed -i '2i Huson规则,config_h.ini,http:\/\/127.0.0.1\/openclash_config_h.ini\nHuson远程规则,remote_config_h.ini,https:\/\/raw.githubusercontent.com\/0x01-0xff\/ProxyProfiles\/master\/Clash\/remote_config_h.ini' feeds/openclash/luci-app-openclash/root/usr/share/openclash/res/sub_ini.list
#curl -SsL --connect-timeout 30 -m 60 --speed-time 30 --speed-limit 1 --retry 2 https://raw.githubusercontent.com/0x01-0xff/OP_Files/master/openclash_config_h.ini -o files/www/openclash_config_h.ini 2>&1
#curl -SsL --connect-timeout 30 -m 60 --speed-time 30 --speed-limit 1 --retry 2 https://raw.githubusercontent.com/0x01-0xff/OP_Files/master/GoogleALL.list -o files/etc/subconverter/rules/GoogleALL.list 2>&1
#curl -SsL --connect-timeout 30 -m 60 --speed-time 30 --speed-limit 1 --retry 2 https://raw.githubusercontent.com/0x01-0xff/OP_Files/master/OpenAi.list -o files/etc/subconverter/rules/OpenAi.list 2>&1
#curl -SsL --connect-timeout 30 -m 60 --speed-time 30 --speed-limit 1 --retry 2 https://raw.githubusercontent.com/0x01-0xff/OP_Files/master/PayPal.list -o files/etc/subconverter/rules/PayPal.list 2>&1
#cp $INSET_FILES_DIR/openclash_config_h.ini files/www/openclash_config_h.ini
cp $INSET_FILES_DIR/openclash_config_h.ini feeds/openclash/luci-app-openclash/root/www/openclash_config_h.ini
cp $INSET_FILES_DIR/GoogleALL.list files/etc/subconverter/rules/GoogleALL.list
cp $INSET_FILES_DIR/OpenAi.list files/etc/subconverter/rules/OpenAi.list
cp $INSET_FILES_DIR/PayPal.list files/etc/subconverter/rules/PayPal.list

echo ">> Inset openclash core"
mkdir -p feeds/openclash/luci-app-openclash/root/etc/openclash/core
curl -SsL --connect-timeout 30 -m 60 --speed-time 30 --speed-limit 1 --retry 2 https://raw.githubusercontent.com/vernesong/OpenClash/core/master/core_version -o feeds/openclash/luci-app-openclash/root/etc/openclash/core/clash_last_version 2>&1
tmp_TUN_CORE_VERSION=$(sed -n 2p feeds/openclash/luci-app-openclash/root/etc/openclash/core/clash_last_version 2>/dev/null)
rm -rf feeds/openclash/luci-app-openclash/root/etc/openclash/core/clash_last_version >/dev/null 2>&1
curl -SsL --connect-timeout 30 -m 60 --speed-time 30 --speed-limit 1 --retry 2 https://raw.githubusercontent.com/vernesong/OpenClash/core/master/premium/clash-linux-$GET_ARCH-"$tmp_TUN_CORE_VERSION".gz -o feeds/openclash/luci-app-openclash/root/etc/openclash/core/clash-tun-linux-$GET_ARCH.gz 2>&1
#gzip -t feeds/openclash/luci-app-openclash/root/etc/openclash/core/clash-tun-linux-$GET_ARCH.gz >/dev/null 2>&1
gzip -d feeds/openclash/luci-app-openclash/root/etc/openclash/core/clash-tun-linux-$GET_ARCH.gz >/dev/null 2>&1
mv feeds/openclash/luci-app-openclash/root/etc/openclash/core/clash-tun-linux-$GET_ARCH feeds/openclash/luci-app-openclash/root/etc/openclash/core/clash_tun >/dev/null 2>&1
rm -rf feeds/openclash/luci-app-openclash/root/etc/openclash/core/clash-tun-linux-$GET_ARCH.gz >/dev/null 2>&1
[ -e feeds/openclash/luci-app-openclash/root/etc/openclash/core/clash_tun ] && echo "clash_tun done."
curl -SsL --connect-timeout 30 -m 60 --speed-time 30 --speed-limit 1 --retry 2 https://raw.githubusercontent.com/vernesong/OpenClash/core/master/meta/clash-linux-$GET_ARCH.tar.gz -o feeds/openclash/luci-app-openclash/root/etc/openclash/core/clash-meta-linux-$GET_ARCH.tar.gz 2>&1
#gzip -t feeds/openclash/luci-app-openclash/root/etc/openclash/core/clash-meta-linux-$GET_ARCH.tar.gz >/dev/null 2>&1
tar zxvf feeds/openclash/luci-app-openclash/root/etc/openclash/core/clash-meta-linux-$GET_ARCH.tar.gz -C feeds/openclash/luci-app-openclash/root/etc/openclash/core >/dev/null 2>&1
mv feeds/openclash/luci-app-openclash/root/etc/openclash/core/clash feeds/openclash/luci-app-openclash/root/etc/openclash/core/clash_meta >/dev/null 2>&1
rm -rf feeds/openclash/luci-app-openclash/root/etc/openclash/core/clash-meta-linux-$GET_ARCH.tar.gz >/dev/null 2>&1
[ -e feeds/openclash/luci-app-openclash/root/etc/openclash/core/clash_meta ] && echo "clash_meta done."
curl -SsL --connect-timeout 30 -m 60 --speed-time 30 --speed-limit 1 --retry 2 https://raw.githubusercontent.com/vernesong/OpenClash/core/master/dev/clash-linux-$GET_ARCH.tar.gz -o feeds/openclash/luci-app-openclash/root/etc/openclash/core/clash-linux-$GET_ARCH.tar.gz 2>&1
#gzip -t feeds/openclash/luci-app-openclash/root/etc/openclash/core/clash-linux-$GET_ARCH.tar.gz >/dev/null 2>&1
tar zxvf feeds/openclash/luci-app-openclash/root/etc/openclash/core/clash-linux-$GET_ARCH.tar.gz -C feeds/openclash/luci-app-openclash/root/etc/openclash/core >/dev/null 2>&1
rm -rf feeds/openclash/luci-app-openclash/root/etc/openclash/core/clash-linux-$GET_ARCH.tar.gz >/dev/null 2>&1
[ -e feeds/openclash/luci-app-openclash/root/etc/openclash/core/clash ] && echo "clash done."
chmod -R 4755 feeds/openclash/luci-app-openclash/root/etc/openclash/core

echo ">> Set permissions"
rm -rf $INSET_FILES_DIR >/dev/null 2>&1
chmod -R 4755 files
#chmod 664 files/usr/share/passwall/0_default_config
#chmod 664 files/usr/share/passwall2/0_default_config
