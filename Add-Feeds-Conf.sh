#!/bin/bash
#
# By Huson
# 2023-06-18
#
# Add Default Feeds Src
#

cat >> feeds.conf.default <<EOF
src-git passwall https://github.com/xiaorouji/openwrt-passwall.git;packages
src-git passwall_luci https://github.com/xiaorouji/openwrt-passwall.git;luci
src-git passwall2 https://github.com/xiaorouji/openwrt-passwall2.git
src-git helloworld https://github.com/fw876/helloworld.git
src-git openclash https://github.com/vernesong/OpenClash.git
src-git subconverter https://github.com/tindy2013/openwrt-subconverter.git
EOF
