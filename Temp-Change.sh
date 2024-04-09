#!/bin/bash
#
# By Huson
# 2024-04-09 02:00
#
# Temporary Changes
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

# **** TMP update v2ray-core ****
V2RAYCORE_MAKEFILE="feeds/${PW_PKG_FEEDS_NAME}/v2ray-core/Makefile"
sed -i 's/=5\.14\.1/=5\.15\.1/g' $V2RAYCORE_MAKEFILE
sed -i 's/51315ec10764a24e6acafa49763307c03eb916205c5d7eb778edb579b4f2e844/461a65a1675f17ad95a2a5ddf0b016247a34aa376ed1738c143e7c6603ab4abd/g' $V2RAYCORE_MAKEFILE

# **** Update golang ****
echo ">> Replace golang up to date"
rm -rf feeds/packages/lang/golang
git clone https://github.com/sbwml/packages_lang_golang -b 22.x feeds/packages/lang/golang
