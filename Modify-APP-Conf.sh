#!/bin/bash
#
# By Huson
# 2024-03-07 10:54
#
# Modify APP Config
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
echo ">> Replace the old native packages"
replaceNETpackages() {
    local _SRC_PACKAGE=$1
    for i in `ls feeds/${_SRC_PACKAGE}`; do
        if [ -e feeds/packages/net/${i} ]; then
           rm -rf feeds/packages/net/${i} && cp -rf feeds/${_SRC_PACKAGE}/${i} feeds/packages/net/${i}
           echo "replace [${i}] from ${_SRC_PACKAGE}."
        fi
    done
}
replaceNETpackages ${SSR_FEEDS_NAME}
replaceNETpackages ${PW_PKG_FEEDS_NAME}

# **** Update golang ****
echo ">> Replace golang up to date"
rm -rf feeds/packages/lang/golang
git clone https://github.com/sbwml/packages_lang_golang -b 22.x feeds/packages/lang/golang

echo ">> Implantation initialization script"
mkdir -p files/root
cp ${INSET_FILES_DIR}/set_op.sh files/root/set_op.sh
[ -e files/root/set_op.sh ] && echo "copy set_op.sh done."
chmod 4755 files/root/set_op.sh

echo ">> Modify passwall/passwall2 xray config"
PW_DEF_CONF_FILE="feeds/${PW_FEEDS_NAME}/luci-app-passwall/root/usr/share/passwall/0_default_config"
PW2_DEF_CONF_FILE="feeds/${PW2_FEEDS_NAME}/luci-app-passwall2/root/usr/share/passwall2/0_default_config"
sed -i '/^config nodes/,$d' $PW_DEF_CONF_FILE
sed -i '/^config nodes/,$d' $PW2_DEF_CONF_FILE
cat ${INSET_FILES_DIR}/pw_xray_config >> $PW_DEF_CONF_FILE
cat ${INSET_FILES_DIR}/pw2_xray_config >> $PW2_DEF_CONF_FILE

echo ">> Implantation new rules lists to passwall"
PW_RULES_DIR="feeds/${PW_FEEDS_NAME}/luci-app-passwall/root/usr/share/passwall/rules"
if [ ! -e $PW_RULES_DIR ]; then mkdir -p $PW_RULES_DIR; fi
rm -f ${PW_RULES_DIR}/gfwlist ${PW_RULES_DIR}/chnroute ${PW_RULES_DIR}/chnroute6 ${PW_RULES_DIR}/chnlist
$CURL_PARAMS https://fastly.jsdelivr.net/gh/Loyalsoldier/v2ray-rules-dat@release/gfw.txt -o ${PW_RULES_DIR}/gfwlist 2>&1
[ -e ${PW_RULES_DIR}/gfwlist ] && echo "gfwlist done."
$CURL_PARAMS https://ispip.clang.cn/all_cn.txt -o ${PW_RULES_DIR}/chnroute 2>&1
[ -e ${PW_RULES_DIR}/chnroute ] && echo "chnroute done."
$CURL_PARAMS https://ispip.clang.cn/all_cn_ipv6.txt -o ${PW_RULES_DIR}/chnroute6 2>&1
[ -e ${PW_RULES_DIR}/chnroute6 ] && echo "chnroute6 done."
$CURL_PARAMS https://fastly.jsdelivr.net/gh/felixonmars/dnsmasq-china-list/accelerated-domains.china.conf -o ${PW_RULES_DIR}/chnlist_tmp1 2>&1
$CURL_PARAMS https://fastly.jsdelivr.net/gh/felixonmars/dnsmasq-china-list/apple.china.conf -o ${PW_RULES_DIR}/chnlist_tmp2 2>&1
$CURL_PARAMS https://fastly.jsdelivr.net/gh/felixonmars/dnsmasq-china-list/google.china.conf -o ${PW_RULES_DIR}/chnlist_tmp3 2>&1
mergeCHNlist() {
    local _GetFile=$1
    local _ListLine
    while read _ListLine; do
        echo "${_ListLine}" | awk -F '/' '{if ($1=="server=") print $2}' >> ${PW_RULES_DIR}/chnlist
    done < ${PW_RULES_DIR}/${_GetFile}
}
mergeCHNlist chnlist_tmp1
mergeCHNlist chnlist_tmp2
mergeCHNlist chnlist_tmp3
if [ -e ${PW_RULES_DIR}/chnlist ]; then
    echo "chnlist done."
    sed -i '/^$/d' ${PW_RULES_DIR}/chnlist >/dev/null 2>&1
    sort -u ${PW_RULES_DIR}/chnlist -o ${PW_RULES_DIR}/chnlist
    rm -f ${PW_RULES_DIR}/chnlist_tmp*
else
    echo "make chnlist error!"
fi
sudo chmod 644 ${PW_RULES_DIR}/gfwlist ${PW_RULES_DIR}/chnroute ${PW_RULES_DIR}/chnroute6 ${PW_RULES_DIR}/chnlist

echo ">> Implantation Loyalsoldier geosite.dat/geoip.dat to v2ray"
GEODAT_DIR="feeds/${PW2_FEEDS_NAME}/luci-app-passwall2/root/usr/share/v2ray"
mkdir -p $GEODAT_DIR
#$CURL_PARAMS https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat -o ${GEODAT_DIR}/geosite_extra.dat 2>&1
#[ -e ${GEODAT_DIR}/geosite_extra.dat ] && echo "geosite_extra.dat done."
#$CURL_PARAMS https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat -o ${GEODAT_DIR}/geoip_extra.dat 2>&1
#[ -e ${GEODAT_DIR}/geoip_extra.dat ] && echo "geoip_extra.dat done."
rm -rf ${GEODAT_DIR}/*.dat
$CURL_PARAMS https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat -o ${GEODAT_DIR}/geosite.dat 2>&1
[ -e ${GEODAT_DIR}/geosite.dat ] && echo "geosite.dat done."
$CURL_PARAMS https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat -o ${GEODAT_DIR}/geoip.dat 2>&1
[ -e ${GEODAT_DIR}/geoip.dat ] && echo "geoip.dat done."
sudo chmod 644 ${GEODAT_DIR}/geosite.dat ${GEODAT_DIR}/geoip.dat

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

echo ">> CleanUp"
rm -rf ${INSET_FILES_DIR} >/dev/null 2>&1
