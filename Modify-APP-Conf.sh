#!/bin/bash
#
# By Huson
# 2024-04-09 02:00
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
GEODAT_MAKEFILE="feeds/${PW_PKG_FEEDS_NAME}/v2ray-geodata/Makefile"
GEO_LAST_VER=$(curl -Ls "https://api.github.com/repos/Loyalsoldier/v2ray-rules-dat/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
GEOIP_HASH=$(curl -Ls "https://github.com/Loyalsoldier/v2ray-rules-dat/releases/download/${GEO_LAST_VER}/geoip.dat.sha256sum" | awk '{print $1}')
GEOSITE_HASH=$(curl -Ls "https://github.com/Loyalsoldier/v2ray-rules-dat/releases/download/${GEO_LAST_VER}/geosite.dat.sha256sum" | awk '{print $1}')
echo "Version: ${GEO_LAST_VER}"
sed -i "s/GEOIP_VER:=.*$/GEOIP_VER:=${GEO_LAST_VER}/g" $GEODAT_MAKEFILE
sed -i "s/GEOSITE_VER:=.*$/GEOSITE_VER:=${GEO_LAST_VER}/g" $GEODAT_MAKEFILE
sed -i 's/https:\/\/github\.com\/v2fly\/geoip\/releases\//https:\/\/github\.com\/Loyalsoldier\/v2ray-rules-dat\/releases\//g' $GEODAT_MAKEFILE
sed -i 's/https:\/\/github\.com\/v2fly\/domain-list-community\/releases\//https:\/\/github\.com\/Loyalsoldier\/v2ray-rules-dat\/releases\//g' $GEODAT_MAKEFILE
sed -i 's/=dlc\.dat/=geosite\.dat/g' $GEODAT_MAKEFILE
sed -i "/define Download\/geoip/,/^  HASH:=.*$/ s/^  HASH:=.*$/  HASH:=${GEOIP_HASH}/" $GEODAT_MAKEFILE
sed -i "/define Download\/geosite/,/^  HASH:=.*$/ s/^  HASH:=.*$/  HASH:=${GEOSITE_HASH}/" $GEODAT_MAKEFILE
# **** v2ray GEODATA ****
GEODAT_DIR="files/usr/share/v2ray"
mkdir -p $GEODAT_DIR
$CURL_PARAMS https://github.com/Loyalsoldier/v2ray-rules-dat/releases/download/${GEO_LAST_VER}/geosite.dat -o ${GEODAT_DIR}/geosite.dat 2>&1
$CURL_PARAMS https://github.com/Loyalsoldier/v2ray-rules-dat/releases/download/${GEO_LAST_VER}/geoip.dat -o ${GEODAT_DIR}/geoip.dat 2>&1
sudo chmod 644 ${GEODAT_DIR}/geosite.dat ${GEODAT_DIR}/geoip.dat

echo ">> Replace packages"
replacePackages() {
    local _SRC_PKG_LOCAL=$1
    local _DST_PKG_LOCAL=$2
    for i in `ls ${_SRC_PKG_LOCAL}`; do
        if [ -e ${_DST_PKG_LOCAL}/${i} ]; then
           cp -rf ${_SRC_PKG_LOCAL}/${i} ${_DST_PKG_LOCAL}/${i}
           echo "replace [${_DST_PKG_LOCAL}/${i}] from ${_SRC_PKG_LOCAL}."
        fi
    done
}
replacePackages feeds/${PW_PKG_FEEDS_NAME} feeds/${SSR_FEEDS_NAME}
replacePackages feeds/${PW_PKG_FEEDS_NAME} feeds/packages/net
replacePackages feeds/${SSR_FEEDS_NAME} feeds/packages/net

