#!/bin/bash
#
# By Huson
# 2023-06-15
#

# Uncomment a feed source
#sed -i 's/^#\(.*helloworld\)/\1/' feeds.conf.default

# Add a feed source
#echo 'src-git passwall https://github.com/xiaorouji/openwrt-passwall' >>feeds.conf.default


cat >> feeds.conf.default <<EOF
src-git passwall https://github.com/xiaorouji/openwrt-passwall.git;packages
src-git passwall_luci https://github.com/xiaorouji/openwrt-passwall.git;luci
src-git passwall2 https://github.com/xiaorouji/openwrt-passwall2.git
src-git helloworld https://github.com/fw876/helloworld.git
src-git openclash https://github.com/vernesong/OpenClash.git
src-git subconverter https://github.com/tindy2013/openwrt-subconverter.git
EOF
