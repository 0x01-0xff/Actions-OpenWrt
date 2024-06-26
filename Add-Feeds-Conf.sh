#!/bin/bash
#
# By Huson
# 2024-04-09 02:00
#
# Add Default Feeds Src
#

if [ ! "`grep "passwall" feeds.conf.default`" ]; then
cat >> feeds.conf.default <<EOF
src-git passwall_pkg https://github.com/xiaorouji/openwrt-passwall-packages.git;main
src-git passwall https://github.com/xiaorouji/openwrt-passwall.git;main
src-git passwall2 https://github.com/xiaorouji/openwrt-passwall2.git;main
src-git helloworld https://github.com/fw876/helloworld.git
#src-git openclash https://github.com/vernesong/OpenClash.git
src-git subconverter https://github.com/tindy2013/openwrt-subconverter.git
EOF
fi


# other src

#rm -rf feeds/packages/net/{xray-core,v2ray-core,v2ray-geodata,sing-box}
#
#git clone https://github.com/sbwml/openwrt_helloworld package/fanqiang
#git clone https://github.com/tindy2013/openwrt-subconverter package/fanqiang
# or
#src-git pw_hw https://github.com/sbwml/openwrt_helloworld.git;v5
#src-git subconverter https://github.com/tindy2013/openwrt-subconverter.git
