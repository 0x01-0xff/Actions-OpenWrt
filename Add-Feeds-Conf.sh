#!/bin/bash
#
# By Huson
# 2023-11-05 18:00
#
# Add Default Feeds Src
#

if [ ! "`grep "passwall" feeds.conf.default`" ]; then
cat >> feeds.conf.default <<EOF
src-git passwall_pkg https://github.com/xiaorouji/openwrt-passwall-packages.git;main
src-git passwall https://github.com/xiaorouji/openwrt-passwall.git;4.73-3
src-git passwall2 https://github.com/xiaorouji/openwrt-passwall2.git;1.25-5
src-git helloworld https://github.com/fw876/helloworld.git
src-git openclash https://github.com/vernesong/OpenClash.git
src-git subconverter https://github.com/tindy2013/openwrt-subconverter.git
EOF
fi
