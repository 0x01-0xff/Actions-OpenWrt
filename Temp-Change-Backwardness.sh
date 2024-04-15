#!/bin/bash
#
# By Huson
# 2024-04-09 02:00
#
# Temporary Changes Backwardness
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

# **** get older passwall packages ****
echo ">> Set older passwall packages"
rm -rf feeds/${PW_PKG_FEEDS_NAME}
git clone https://github.com/xiaorouji/openwrt-passwall-packages.git feeds/${PW_PKG_FEEDS_NAME}
cd feeds/${PW_PKG_FEEDS_NAME}
git reset --hard 1946200
cd ../..

# **** get older helloworld ****
echo ">> Set older helloworld"
rm -rf feeds/${SSR_FEEDS_NAME}
git clone https://github.com/fw876/helloworld.git feeds/${SSR_FEEDS_NAME}
cd feeds/${SSR_FEEDS_NAME}
git reset --hard 4d5fb92
cd ../..

# **** Update golang ****
echo ">> Replace golang up to date"
rm -rf feeds/packages/lang/golang
git clone https://github.com/sbwml/packages_lang_golang -b 21.x feeds/packages/lang/golang

# **** Sing-box GEODATA ****
SB_GEO_DIR="files/usr/share/singbox"
mkdir -p $SB_GEO_DIR
#$CURL_PARAMS https://github.com/SagerNet/sing-geosite/releases/latest/download/geosite.db -o ${SB_GEO_DIR}/geosite.db 2>&1
#$CURL_PARAMS https://github.com/SagerNet/sing-geoip/releases/latest/download/geoip.db -o ${SB_GEO_DIR}/geoip.db 2>&1
$CURL_PARAMS https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geosite.db -o ${SB_GEO_DIR}/geosite.db 2>&1
$CURL_PARAMS https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geoip.db -o ${SB_GEO_DIR}/geoip.db 2>&1
sudo chmod 644 ${SB_GEO_DIR}/geosite.db ${SB_GEO_DIR}/geoip.db

