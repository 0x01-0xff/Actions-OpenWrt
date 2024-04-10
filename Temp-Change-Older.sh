#!/bin/bash
#
# By Huson
# 2024-04-09 02:00
#
# Temporary Changes Older
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

# **** get older passwall 早期的tag号里只有packages，所以只能使用commit指针调取旧版本v4.69-4 ****
echo ">> Set older passwall"
rm -rf feeds/${PW_FEEDS_NAME}
git clone https://github.com/xiaorouji/openwrt-passwall.git feeds/${PW_FEEDS_NAME}
cd feeds/${PW_FEEDS_NAME}
git reset --hard d1e6182
cd ../..

# **** get older passwall packages ****
#echo ">> Set older passwall packages"
#rm -rf feeds/${PW_PKG_FEEDS_NAME}
#git clone https://github.com/xiaorouji/openwrt-passwall-packages.git feeds/${PW_PKG_FEEDS_NAME}
#cd feeds/${PW_PKG_FEEDS_NAME}
#git reset --hard c189a68
#cd ../..

# Fix shadowsocks-rust build error
#rm -rf feeds/${PW_PKG_FEEDS_NAME}/shadowsocks-rust/Makefile
#$CURL_PARAMS https://raw.githubusercontent.com/sbwml/openwrt_helloworld/v5/shadowsocks-rust/Makefile -o feeds/${PW_PKG_FEEDS_NAME}/shadowsocks-rust/Makefile 2>&1

# **** get older helloworld ****
echo ">> Set older helloworld"
rm -rf feeds/${SSR_FEEDS_NAME}
git clone https://github.com/fw876/helloworld.git feeds/${SSR_FEEDS_NAME}
cd feeds/${SSR_FEEDS_NAME}
git reset --hard b060fd5
cd ../..

# **** Update golang ****
echo ">> Replace golang up to date"
rm -rf feeds/packages/lang/golang
git clone https://github.com/sbwml/packages_lang_golang -b 20.x feeds/packages/lang/golang

