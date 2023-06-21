#!/bin/bash
#
# By Huson
# 2023-06-21 13:09
#
# Remove the Old Native Packages
#


echo ">> Remove the old native packages"
[ -e feeds/package/net/haproxy ] && rm -rf feeds/package/net/haproxy 2>/dev/null
[ -e feeds/package/net/shadowsocks-libev ] && rm -rf feeds/package/net/shadowsocks-libev 2>/dev/null
[ -e feeds/package/net/trojan-go] && rm -rf feeds/package/net/trojan-go 2>/dev/null
[ -e feeds/package/net/v2ray-core ] && rm -rf feeds/package/net/v2ray-core 2>/dev/null
[ -e feeds/package/net/v2raya ] && rm -rf feeds/package/net/v2raya 2>/dev/null
[ -e feeds/package/net/v2ray-geodata ] && rm -rf feeds/package/net/v2ray-geodata 2>/dev/null
[ -e feeds/package/net/xray-core ] && rm -rf feeds/package/net/xray-core 2>/dev/null

