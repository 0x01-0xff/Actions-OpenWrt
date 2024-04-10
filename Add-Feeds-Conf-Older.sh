#!/bin/bash
#
# By Huson
# 2024-04-09 02:00
#
# Add Default Feeds Src Older version
#
# passwall 1&2 without sing-box
#

if [ ! "`grep "passwall" feeds.conf.default`" ]; then
cat >> feeds.conf.default <<EOF
#src-git passwall_pkg https://github.com/xiaorouji/openwrt-passwall-packages.git;main
# 4.69-4的tag号里只有passwall-packages，所以当pkg用
src-git passwall_pkg https://github.com/xiaorouji/openwrt-passwall.git;4.69-4
src-git passwall https://github.com/xiaorouji/openwrt-passwall.git;main
src-git passwall2 https://github.com/xiaorouji/openwrt-passwall2.git;1.19-6
src-git helloworld https://github.com/fw876/helloworld.git
#src-git openclash https://github.com/vernesong/OpenClash.git
src-git subconverter https://github.com/tindy2013/openwrt-subconverter.git
EOF
fi
