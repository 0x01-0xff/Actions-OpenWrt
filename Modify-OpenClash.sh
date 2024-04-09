#!/bin/bash
#
# By Huson
# 2024-04-09 02:00
#
# Implantation files to openclash
#
INSET_FILES_DIR=$1
GET_ARCH=$2
#
PW_PKG_FEEDS_NAME="passwall_pkg"
PW_FEEDS_NAME="passwall"
PW2_FEEDS_NAME="passwall2"
SSR_FEEDS_NAME="helloworld"
OC_FEEDS_NAME="openclash"
SC_FEEDS_NAME="subconverter"
#
CURL_PARAMS="curl -SsL --connect-timeout 30 -m 60 --speed-time 30 --speed-limit 1 --retry 2"
#
#######################################

echo ">> Implantation rules set and convert server to openclash"
OC_SUB_LUA_FILE="feeds/${OC_FEEDS_NAME}/luci-app-openclash/luasrc/model/cbi/openclash/config-subscribe-edit.lua"
OC_SUB_INI_FILE="feeds/${OC_FEEDS_NAME}/luci-app-openclash/root/usr/share/openclash/res/sub_ini.list"
GET_SUB_SERVER=$(grep -B1 '^o:value("https:\/\/api.dler.io\/sub"' $OC_SUB_LUA_FILE | sed -n 1p 2>/dev/null)
GET_SUB_SERVER=${GET_SUB_SERVER: 17: 9}
if [ ! "$GET_SUB_SERVER" == "127.0.0.1" ]; then
    sed -i 's/o:value("https:\/\/api.dler.io\/sub"/o:value("https:\/\/127.0.0.1:25500\/sub", translate("127.0.0.1")..translate("(Router Side Service)"))\no:value("https:\/\/api.dler.io\/sub"/g' $OC_SUB_LUA_FILE
    sed -i 's/o.default = "https:\/\/api.dler.io\/sub"/o.default = "https:\/\/127.0.0.1:25500\/sub"/g' $OC_SUB_LUA_FILE
    echo "addition 127.0.0.1 subconverter server done."
fi
GET_RULES_CON=$(sed -n 2p $OC_SUB_INI_FILE 2>/dev/null)
if [ ! "${GET_RULES_CON: 0: 5}" == "Huson" ]; then
    sed -i '2i Huson规则,config_h.ini,http:\/\/127.0.0.1\/openclash_config_h.ini\nHuson远程规则,remote_config_h.ini,https:\/\/raw.githubusercontent.com\/0x01-0xff\/ProxyProfiles\/master\/Clash\/remote_config_h.ini' $OC_SUB_INI_FILE
    echo "addition Huson rules done."
    cp ${INSET_FILES_DIR}/openclash_config_h.ini feeds/${OC_FEEDS_NAME}/luci-app-openclash/root/www/openclash_config_h.ini
    [ -e feeds/${OC_FEEDS_NAME}/luci-app-openclash/root/www/openclash_config_h.ini ] && echo "copy config file done."
    mkdir -p files/etc/subconverter/rules
    cp ${INSET_FILES_DIR}/GoogleALL.list files/etc/subconverter/rules/GoogleALL.list
    cp ${INSET_FILES_DIR}/OpenAi.list files/etc/subconverter/rules/OpenAi.list
    cp ${INSET_FILES_DIR}/PayPal.list files/etc/subconverter/rules/PayPal.list
fi

echo ">> Implantation openclash core"
OC_CORE_DIR="feeds/${OC_FEEDS_NAME}/luci-app-openclash/root/etc/openclash/core"
mkdir -p ${OC_CORE_DIR}
$CURL_PARAMS https://raw.githubusercontent.com/vernesong/OpenClash/core/master/core_version -o ${OC_CORE_DIR}/clash_last_version 2>&1
TUN_CORE_VERSION=$(sed -n 2p ${OC_CORE_DIR}/clash_last_version 2>/dev/null)
rm -rf ${OC_CORE_DIR}/clash_last_version >/dev/null 2>&1
$CURL_PARAMS https://raw.githubusercontent.com/vernesong/OpenClash/core/master/premium/clash-linux-${GET_ARCH}-"${TUN_CORE_VERSION}".gz -o ${OC_CORE_DIR}/clash-tun-linux-${GET_ARCH}.gz 2>&1
gzip -d ${OC_CORE_DIR}/clash-tun-linux-${GET_ARCH}.gz >/dev/null 2>&1
mv ${OC_CORE_DIR}/clash-tun-linux-${GET_ARCH} ${OC_CORE_DIR}/clash_tun >/dev/null 2>&1
rm -rf ${OC_CORE_DIR}/clash-tun-linux-${GET_ARCH}.gz >/dev/null 2>&1
[ -e ${OC_CORE_DIR}/clash_tun ] && echo "clash_tun done."
$CURL_PARAMS https://raw.githubusercontent.com/vernesong/OpenClash/core/master/meta/clash-linux-${GET_ARCH}.tar.gz -o ${OC_CORE_DIR}/clash-meta-linux-${GET_ARCH}.tar.gz 2>&1
tar zxvf ${OC_CORE_DIR}/clash-meta-linux-${GET_ARCH}.tar.gz -C ${OC_CORE_DIR} >/dev/null 2>&1
mv ${OC_CORE_DIR}/clash ${OC_CORE_DIR}/clash_meta >/dev/null 2>&1
rm -rf ${OC_CORE_DIR}/clash-meta-linux-${GET_ARCH}.tar.gz >/dev/null 2>&1
[ -e ${OC_CORE_DIR}/clash_meta ] && echo "clash_meta done."
$CURL_PARAMS https://raw.githubusercontent.com/vernesong/OpenClash/core/master/dev/clash-linux-${GET_ARCH}.tar.gz -o ${OC_CORE_DIR}/clash-linux-${GET_ARCH}.tar.gz 2>&1
tar zxvf ${OC_CORE_DIR}/clash-linux-${GET_ARCH}.tar.gz -C ${OC_CORE_DIR} >/dev/null 2>&1
rm -rf ${OC_CORE_DIR}/clash-linux-${GET_ARCH}.tar.gz >/dev/null 2>&1
[ -e ${OC_CORE_DIR}/clash ] && echo "clash done."
chmod -R 4755 ${OC_CORE_DIR}

