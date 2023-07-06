#!/bin/sh
_settingType="$1"
# Openwrt Setting Script Base on v22.03.5 x86_64
# Huson 2023-07-06 11:51
# IP Assign: MainRouter:1, NAS:10, TV:50-59, AP:200-253, AC:254, NormalDHCP:100-199
# Bypass Main Network: MainRouter:1, ViceRouter:2, VM:3, NAS:10, TV:50-59, AP:200-253, AC:254, NormalDHCP:10.0.1.11-254
# USE: # sh set_op.sh [normal/bypass]
#
########## BYPASS SETTING ########## BYPASS SETTING ##########
# Bypass Mode Only Need to Set This Variable.
Vice_Router_Ip="10.0.0.2"; Main_Router_Ip="10.0.0.1"; Main_Router_Mask="255.255.254.0"
Host_Name_Bypass="Vice-Router"
########## BYPASS SETTING ########## BYPASS SETTING ##########

########## NORMAL SETTING ########## NORMAL SETTING ##########
#******# System Setting
Host_Name="HusonRouter"
Zone_Name="Asia/Shanghai"
Time_Zone="CST-8"
Router_Domain="router.hs"
Vice_Router_Domain="vicerouter.hs"
if [ "$_settingType" == "bypass" ]; then Host_Name="$Host_Name_Bypass"; fi

#******# Router MAC Address
Mac_Port1="00:90:27:E2:33:00"; Mac_Port2="00:90:27:E2:33:00"; Mac_Port3="00:90:27:E2:33:00"; Mac_Port4="00:90:27:E2:33:00"

#******# IP Address Prefix
IP_HEAD_1="10.0.0"; IP_HEAD_2="10.10.10"; IP_HEAD_3="192.168.0"

#******# LAN Setting
###############################################################################
## Exp: Lan1_Mac=""; Lan1_Ip_Head=""; Lan1_Ip=""; Lan1_Mask=""; Lan1_Dhcp_Start="100"; Lan1_Dhcp_End="199"
###############################################################################
Lan1_Mac="$Mac_Port3"; Lan1_Ip_Head="${IP_HEAD_1}"; Lan1_Ip="${Lan1_Ip_Head}.1"; Lan1_Mask="255.255.255.0"; Lan1_Dhcp_Start="100"; Lan1_Dhcp_End="199"
Lan2_Mac="$Mac_Port4"; Lan2_Ip_Head="${IP_HEAD_2}"; Lan2_Ip="${Lan2_Ip_Head}.1"; Lan2_Mask="255.255.255.0"; Lan2_Dhcp_Start="11"; Lan2_Dhcp_End="254"

#******# WAN Setting
###############################################################################
## Exp: Wan1_Mac=""; Wan1_Type="pppoe"; Wan1_User="138@139.gd"; Wan1_Pass="123"; Wan1_Disable="no"
##      Wan2_Mac=""; Wan2_Type="dhcp"; Wan2_Disable="no"
##      Wan3_Mac=""; Wan3_Type="static"; Wan3_Ip=""; Wan3_Mask=""; Wan3_Gateway=""; Wan3_Dns=""; Wan3_Disable="yes"
###############################################################################
Wan1_Mac="$Mac_Port1"; Wan1_Type="pppoe"; Wan1_User="138@139.gd"; Wan1_Pass="123"; Wan1_Disable="no"
Wan2_Mac="$Mac_Port2"; Wan2_Type="dhcp"; Wan2_Disable="no"

#******# Device Domain and IP
Router_Ip="${Lan1_Ip}"
###############################################################################
## Exp: Dev1_Name=""; Dev1_Mac=""; Dev1_Ip=""; Dev1_Ports="80,443"; Dev1_Domain=""
###############################################################################
Dev1_Name="KT-MITV3-60"; Dev1_Mac="48:A9:D2:A6:31:EC"; Dev1_Ip="${Lan1_Ip_Head}.50"; Dev1_Ports=""; Dev1_Domain=""
Dev2_Name="AP1-TLAP1750GC"; Dev2_Mac="9C:A6:15:4D:7E:32"; Dev2_Ip="${Lan1_Ip_Head}.200"; Dev2_Ports=""; Dev2_Domain=""
Dev3_Name="TL-AC100"; Dev3_Mac="CC:08:FB:6B:CF:C0"; Dev3_Ip="${Lan1_Ip_Head}.254"; Dev3_Ports=""; Dev3_Domain="ac.hs"


###############################################################################
##                                  FUNCTION                                 ##
###############################################################################
_red()     { printf '\033[0;31;31m'; printf "$@"; printf '\033[0m'; }; _redH()    { printf '\033[1;31;31m'; printf "$@"; printf '\033[0m'; }
_green()   { printf '\033[0;31;32m'; printf "$@"; printf '\033[0m'; }; _greenH()  { printf '\033[1;31;32m'; printf "$@"; printf '\033[0m'; }
_yellow()  { printf '\033[0;31;33m'; printf "$@"; printf '\033[0m'; }; _yellowH() { printf '\033[1;31;33m'; printf "$@"; printf '\033[0m'; }
_blue()    { printf '\033[0;31;34m'; printf "$@"; printf '\033[0m'; }; _blueH()   { printf '\033[1;31;34m'; printf "$@"; printf '\033[0m'; }
_white()   { printf '\033[0;31;37m'; printf "$@"; printf '\033[0m'; }; _whiteH()  { printf '\033[1;31;37m'; printf "$@"; printf '\033[0m'; }

checkPackageInstalled() {
	local _chkPackageName="$1"
	if [ -z "$(opkg info ${_chkPackageName})" ]; then
		_red "Error: \"${_chkPackageName}\" not found.\n"
		_yellow "Install ${_chkPackageName} first, and try again\n"
		exit 1
	fi
}
checkMacExistence() {
	local _chkDstMac="$1"
	local i
	for i in `ls /sys/class/net | grep "eth"`; do
		if [ "$(cat /sys/class/net/$i/address | tr '[a-z]' '[A-Z]')" == "$_chkDstMac" ]; then
			return 0
		fi
	done
	_red "MAC:$_chkDstMac No Found on This Device.\n"
	exit 1
}
comparisonProtMac() {
	local _nkClass="$1"
	local x=1
	while [ ! -z $(eval echo '$'${_nkClass}${x}'_Mac') ]; do
		checkMacExistence "$(eval echo '$'${_nkClass}${x}'_Mac')"
		let x++
	done
}
set_system_info() {
	uci set system.@system[0].hostname=${Host_Name}
	uci set system.@system[0].zonename=${Zone_Name}
	uci set system.@system[0].timezone=${Time_Zone}
	uci commit system
	_green "[System]: Set Router Name to ${Host_Name}, Time-zone ${Time_Zone}\n"
}
disable_service() {
	if [ -f /etc/init.d/banip ]; then /etc/init.d/banip stop && /etc/init.d/banip disable; fi
	if [ -f /etc/init.d/ddns ]; then /etc/init.d/ddns stop && /etc/init.d/ddns disable; fi
	if [ -f /etc/init.d/frpc ]; then /etc/init.d/frpc stop && /etc/init.d/frpc disable; fi
	if [ -f /etc/init.d/frps ]; then /etc/init.d/frps stop && /etc/init.d/frps disable; fi
	if [ -f /etc/init.d/https-dns-proxy ]; then /etc/init.d/https-dns-proxy stop && /etc/init.d/https-dns-proxy disable; fi
	if [ -f /etc/init.d/pbr ]; then /etc/init.d/pbr stop && /etc/init.d/pbr disable; fi
}
set_ssh_server() {
	uci set dropbear.@dropbear[0].PasswordAuth=on
	uci set dropbear.@dropbear[0].RootPasswordAuth=on
	uci set dropbear.@dropbear[0].Port=22
	uci set dropbear.@dropbear[0].Interface=lan
	uci commit dropbear
	_green "[SSH]: Set SSH Server to Lan on Port 22\n"
}
uciDelMultiConfigSection() {
	local _delConfigSection="$1"
	local o=0
	while [ ! -z $(uci -q get ${_delConfigSection}[$o]) ]; do
		uci delete ${_delConfigSection}[$o]
		let o++
	done
}
getEthNameViaMac() {
	local _portMac="$(echo "$1" | tr '[a-z]' '[A-Z]')"
	local _systemEth
	for z in `ls /sys/class/net | grep "eth"`; do
		if [ "`cat /sys/class/net/$z/address | tr '[a-z]' '[A-Z]'`" == "$_portMac" ]; then _systemEth="$z"; fi
	done
	echo "$_systemEth"
}
getInterfaceNameGroup() {
	local _networkClass="$1"
	local _iFaceClass _typeName _typeNameGroup
	local x=1
	if [ "${_networkClass}" == "Lan" ]; then _iFaceClass="lan"; elif [ "${_networkClass}" == "Wan" ]; then _iFaceClass="wan"; fi
	while [ ! -z $(eval echo '$'${_networkClass}${x}'_Mac') ]; do
		if [ $x = 1 ]; then _typeName="${_iFaceClass}"; else _typeName=" ${_iFaceClass}${x}"; fi
		_typeNameGroup="${_typeNameGroup}${_typeName}"
		let x++
	done
	echo "${_typeNameGroup}"
}
getEthBridgeGroup() {
	for z in `ls /sys/class/net | grep "eth"`; do
		echo "	list ports '$z'"
	done
}
addInterfaceToNetwork() {
	local _nkClass="$1"
	local _ifClass _ifName _ifProto
	local x=1
	if [ "${_nkClass}" == "Lan" ]; then _ifClass="lan"; elif [ "${_nkClass}" == "Wan" ]; then _ifClass="wan"; fi
	while [ ! -z $(eval echo '$'${_nkClass}${x}'_Mac') ]; do
		if [ $x = 1 ]; then _ifName="${_ifClass}"; else _ifName="${_ifClass}${x}"; fi
		if [ "$_ifClass" == "lan" ]; then _ifProto="static"; else _ifProto="$(eval echo '$'${_nkClass}${x}'_Type')"; fi
		echo "config interface '$_ifName'"
		echo "	option device '$(getEthNameViaMac $(eval echo '$'${_nkClass}${x}'_Mac'))'"
		echo "	option proto '$_ifProto'"
		if [ "$_ifClass" == "lan" ]; then
			echo "	option ipaddr '$(eval echo '$'${_nkClass}${x}'_Ip')'"
			echo "	option netmask '$(eval echo '$'${_nkClass}${x}'_Mask')'"
			echo "	option ip6assign '60'"
		fi
		if [ "$_ifClass" == "wan" ] && [ "$_ifProto" == "pppoe" ]; then
			echo "	option username '$(eval echo '$'${_nkClass}${x}'_User')'"
			echo "	option password '$(eval echo '$'${_nkClass}${x}'_Pass')'"
			echo "	option ipv6 'auto'"
		elif [ "$_ifClass" == "wan" ] && [ "$_ifProto" == "static" ]; then
			echo "	option ipaddr '$(eval echo '$'${_nkClass}${x}'_Ip')'"
			echo "	option netmask '$(eval echo '$'${_nkClass}${x}'_Mask')'"
			echo "	option gateway '$(eval echo '$'${_nkClass}${x}'_Gateway')'"
			echo "	option dns '$(eval echo '$'${_nkClass}${x}'_Dns')'"
		fi
		if [ "$_ifClass" == "wan" ] && [ "$(eval echo '$'${_nkClass}${x}'_Disable')" == "yes" ]; then
			echo "	option auto '0'"
		fi
		echo ""
		let x++
	done
}
set_dhcp_pool() {
	local _dhcpIfName _dhcpLimit
	local i=1
	while [ ! -z $(eval echo '$Lan'$i'_Mac') ]; do
		if [ $i = 1 ]; then _dhcpIfName="lan"; else _dhcpIfName="lan$i"; fi
		_dhcpLimit=$(($(eval echo '$Lan'$i'_Dhcp_End')-$(eval echo '$Lan'$i'_Dhcp_Start')+1))
		uci set dhcp.${_dhcpIfName}=dhcp
		uci set dhcp.${_dhcpIfName}.interface=${_dhcpIfName}
		uci set dhcp.${_dhcpIfName}.leasetime=12h
		uci set dhcp.${_dhcpIfName}.start=$(eval echo '$Lan'$i'_Dhcp_Start')
		uci set dhcp.${_dhcpIfName}.limit=$_dhcpLimit
		_green "[Dhcp]: Set \"${_dhcpIfName}\" DhcpPool $(eval echo '$Lan'$i'_Ip_Head').$(eval echo '$Lan'$i'_Dhcp_Start')-$(eval echo '$Lan'$i'_Ip_Head').$(eval echo '$Lan'$i'_Dhcp_End')\n"
		let i++
	done
	uci commit dhcp
}
bypass_disable_dhcp_server() {
	uci set dhcp.lan.ignore=1
	uci set dhcp.lan.dynamicdhcp=0
	uci set dhcp.lan.dhcpv6=0
	uci set dhcp.lan.ra=relay
	uci set dhcp.lan.ndp=relay
	#uci set dhcp.wan.ignore=1
	uci set dhcp.odhcpd.maindhcp=0
	uci set dhcp.@dnsmasq[0].noresolv=1
	uci set dhcp.@dnsmasq[0].nohosts=1
	uci set dhcp.@dnsmasq[0].authoritative=0
	uci set dhcp.@dnsmasq[0].boguspriv=0
	uci set dhcp.@dnsmasq[0].readethers=0
	uci set dhcp.@dnsmasq[0].domainneeded=1
	uci set dhcp.@dnsmasq[0].localise_queries=1
	uci set dhcp.@dnsmasq[0].rebind_protection=1
	uci set dhcp.@dnsmasq[0].rebind_localhost=1
	uci set dhcp.@dnsmasq[0].expandhosts=1
	uci set dhcp.@dnsmasq[0].nonwildcard=1
	uci set dhcp.@dnsmasq[0].localservice=1
	uci set dhcp.@dnsmasq[0].server=${Main_Router_Ip}#53
	uci commit dhcp
	_green "[Dhcp]: Dhcp Server Disabled\n"
}
insert_network_interface() {
	#uci delete network.wan6
	#uci commit network
	#sleep 3
	local _nkPrefix="$(uci get network.globals.ula_prefix)"
	cat > /etc/config/network << EOF
config interface 'loopback'
	option device 'lo'
	option proto 'static'
	option ipaddr '127.0.0.1'
	option netmask '255.0.0.0'

config globals 'globals'
	option ula_prefix '${_nkPrefix}'
		
$(addInterfaceToNetwork "Lan")

$(addInterfaceToNetwork "Wan")
EOF
	set_dhcp_pool
	_green "[Network]: Inserted Network Parameters\n"
}
insert_bypass_network_interface() {
	local _nkPrefix="$(uci get network.globals.ula_prefix)"
	cat > /etc/config/network << EOF
config interface 'loopback'
	option device 'lo'
	option proto 'static'
	option ipaddr '127.0.0.1'
	option netmask '255.0.0.0'

config globals 'globals'
	option ula_prefix '${_nkPrefix}'

config device
	option name 'br-lan'
	option type 'bridge'
$(getEthBridgeGroup)

config interface 'lan'
	option device 'br-lan'
	option proto 'static'
	option ipaddr '${Vice_Router_Ip}'
	option netmask '${Main_Router_Mask}'
	option gateway '${Main_Router_Ip}'
	option delegate '0'
	option ip6assign '60'
EOF
	#option dns '${Main_Router_Ip}'
	#uci set network.lan.dns=${Main_Router_Ip}
	_green "[Network]: Inserted Network Parameters\n"
}
process_firewall_zone() {
	local _fwZoneLanN _fwZoneWanN _fwIfaceLan _fwIfaceWan _fwGetZoneName
	local i=0
	while [ ! -z $(uci -q get firewall.@zone[$i]) ]; do
		if [ "$(uci -q get firewall.@zone[$i].name)" == "lan" ]; then
			_fwZoneLanN="$i"
		elif [ "$(uci -q get firewall.@zone[$i].name)" == "wan" ]; then
			_fwZoneWanN="$i"
		fi
		let i++
	done
	_fwIfaceLan="$(getInterfaceNameGroup "Lan")"
	_fwIfaceWan="$(getInterfaceNameGroup "Wan")"
	if [ -z $_fwZoneLanN ]; then
		_fwZoneLanN=$i
		uci add firewall zone > /dev/null
	fi
	uci set firewall.@zone[$_fwZoneLanN].name=lan
	uci set firewall.@zone[$_fwZoneLanN].network="${_fwIfaceLan}"
	uci set firewall.@zone[$_fwZoneLanN].input=ACCEPT
	uci set firewall.@zone[$_fwZoneLanN].output=ACCEPT
	uci set firewall.@zone[$_fwZoneLanN].forward=ACCEPT
	_green "[Firewall]: Added \"$_fwIfaceLan\" to Lan Zone[$_fwZoneLanN]\n"
	if [ -z $_fwZoneWanN ]; then
		_fwZoneWanN=$(($_fwZoneLanN+1))
		uci add firewall zone > /dev/null
	fi
	uci set firewall.@zone[$_fwZoneWanN].name=wan
	uci set firewall.@zone[$_fwZoneWanN].network="${_fwIfaceWan}"
	uci set firewall.@zone[$_fwZoneWanN].input=REJECT
	uci set firewall.@zone[$_fwZoneWanN].output=ACCEPT
	uci set firewall.@zone[$_fwZoneWanN].forward=REJECT
	uci set firewall.@zone[$_fwZoneWanN].masq=1
	uci set firewall.@zone[$_fwZoneWanN].mtu_fix=1
	_green "[Firewall]: Added \"$_fwIfaceWan\" to Wan Zone[$_fwZoneWanN]\n"
	# Delete other zone
	local j=0
	while [ ! -z $(uci -q get firewall.@zone[$j]) ]; do
		_fwGetZoneName="$(uci get firewall.@zone[$j].name)"
		if ! ([ "$_fwGetZoneName" == "lan" ] || [ "$_fwGetZoneName" == "wan" ]); then
			uci delete firewall.@zone[$j]
			_yellow "[Firewall]: Deleted zone[$j]: \"$_fwGetZoneName\"\n"
		fi
		let j++
	done
}
insert_port_dst_nat() {
	local _dstDevName _dstFwName _dstDevPorts
	local i=1
	while [ ! -z "$(eval echo '$Dev'$i'_Name')" ] && [ ! -z $(eval echo '$Dev'$i'_Ip') ] && [ ! -z $(eval echo '$Dev'$i'_Ports') ]; do
		_dstDevName="$(eval echo '$Dev'$i'_Name')"
		_dstFwName="$(echo $_dstDevName | tr '[A-Z]' '[a-z]')"
		_dstFwName=${_dstFwName// /_}
		_dstFwName=${_dstFwName//-/_}
		_dstDevPorts="$(eval echo '$Dev'$i'_Ports')"
		_dstDevPorts="${_dstDevPorts//,/ }"
		for j in $_dstDevPorts; do
			uci set firewall.${_dstFwName}_${j}=redirect
			uci set firewall.${_dstFwName}_${j}.name="${_dstDevName}_${j}"
			uci set firewall.${_dstFwName}_${j}.target=DNAT
			uci set firewall.${_dstFwName}_${j}.src=wan
			uci set firewall.${_dstFwName}_${j}.dest=lan
			uci set firewall.${_dstFwName}_${j}.proto="tcp udp"
			uci set firewall.${_dstFwName}_${j}.src_dport=$j
			uci set firewall.${_dstFwName}_${j}.dest_ip="$(eval echo '$Dev'$i'_Ip')"
			uci set firewall.${_dstFwName}_${j}.dest_port=$j
			_green "[Port Dst Nat]: Added $_dstDevName -> $j\n"
		done
		let i++
	done
}
insert_firewall_interface() {
	uci set firewall.@defaults[0].flow_offloading=1
	# Only MT7621
	#uci set firewall.@defaults[0].flow_offloading_hw=1
	process_firewall_zone
	insert_port_dst_nat
	uci commit firewall
}
bypass_firewall_interface() {
	uci set firewall.@defaults[0].syn_flood=0
	uci set firewall.@defaults[0].flow_offloading=1
	uci set firewall.@defaults[0].input=REJECT
	uci set firewall.@defaults[0].output=REJECT
	uci set firewall.@defaults[0].forward=REJECT
	uci set firewall.@zone[0].name=lan
	uci set firewall.@zone[0].network=lan
	uci set firewall.@zone[0].input=ACCEPT
	uci set firewall.@zone[0].output=ACCEPT
	uci set firewall.@zone[0].forward=ACCEPT
	uci set firewall.@zone[0].masq=0
	uci set firewall.@zone[0].mtu_fix=0
	#uci set firewall.@zone[0].conntrack=1
	#uci set firewall.@zone[0].family=ipv4
	uci set firewall.@forwarding[0].src=lan
	uci set firewall.@forwarding[0].dest=lan
	local i=1
	while [ ! -z $(uci -q get firewall.@zone[$i]) ]; do
		uci delete firewall.@zone[$i]
		let i++
	done
	uci commit firewall
	_green "[Firewall]: Bypass inserted\n"
}
bind_ip_and_domain() {
	local _ipBindedMsg _domainBindedMsg
	local i=1
	local j=0
	local k=0
	if [ ! -z $Router_Ip ] && [ ! -z $Router_Domain ]; then
		uci add dhcp domain > /dev/null
		uci set dhcp.@domain[$k].name=$Router_Domain
		uci set dhcp.@domain[$k].ip=$Router_Ip
		_green "[Binded]: Router Domain: $Router_Domain\n"
		let k++
	fi
	while [ ! -z "$(eval echo '$Dev'$i'_Name')" ]; do
		if [ ! -z $(eval echo '$Dev'$i'_Mac') ] && [ ! -z $(eval echo '$Dev'$i'_Ip') ]; then
			uci add dhcp host > /dev/null
			uci set dhcp.@host[$j].name="$(eval echo '$Dev'$i'_Name')"
			uci set dhcp.@host[$j].mac=$(eval echo '$Dev'$i'_Mac')
			uci set dhcp.@host[$j].ip=$(eval echo '$Dev'$i'_Ip')
			_ipBindedMsg="-> $(eval echo '$Dev'$i'_Ip')"
			if [ ! -z $(eval echo '$Dev'$i'_Domain') ]; then
				uci add dhcp domain > /dev/null
				uci set dhcp.@domain[$k].name=$(eval echo '$Dev'$i'_Domain')
				uci set dhcp.@domain[$k].ip=$(eval echo '$Dev'$i'_Ip')
				_domainBindedMsg=", Domain: $(eval echo '$Dev'$i'_Domain')"
				let k++
			fi
			_green "[Binded]: $(eval echo '$Dev'$i'_Name') ${_ipBindedMsg}${_domainBindedMsg}\n"
			let j++
		fi
		let i++
	done
	uci commit dhcp
}
bypass_bind_router_domain() {
	uci add dhcp domain > /dev/null
	uci set dhcp.@domain[0].name=$Router_Domain
	uci set dhcp.@domain[0].ip=$Main_Router_Ip
	_green "[Binded]: Router Domain: $Router_Domain\n"
	uci add dhcp domain > /dev/null
	uci set dhcp.@domain[1].name=$Vice_Router_Domain
	uci set dhcp.@domain[1].ip=$Vice_Router_Ip
	_green "[Binded]: Vice-Router Domain: $Vice_Router_Domain\n"
	uci commit dhcp
}
set_adblock_sources_list() {
	local _workTrigger="$1"
	local _block_lists="adaway adguard easylist reg_cn reg_es reg_jp reg_ru yoyo"
	if [ -f /etc/init.d/adblock ]; then
		uci set adblock.global.adb_enabled=1
		uci set adblock.global.adb_trigger=${_workTrigger}
		uci set adblock.global.adb_sources=''
#		uci set adblock.global.adb_sources="adaway adguard easylist reg_cn reg_es reg_jp reg_ru yoyo"
		for i in ${_block_lists}; do
			uci add_list adblock.global.adb_sources=$i
		done
		_green "[Adblock]: Sources Lists Done, Trigger: ${_workTrigger}\n"
		uci commit adblock
		_greenH "Restarting Adblock...\n" &
		/etc/init.d/adblock restart >/dev/null 2>&1
		wait
		sleep 2
	fi
}
###############################################################################
##                                FUNCTION END                               ##
###############################################################################

case "$_settingType" in
	normal)
		comparisonProtMac "Lan"
		comparisonProtMac "Wan"
		checkPackageInstalled "dnsmasq-full"
		set_system_info
		disable_service
#		set_ssh_server
		insert_network_interface
		insert_firewall_interface
		bind_ip_and_domain
		set_adblock_sources_list "wan"
		_greenH "Openwrt Normal Mode Setting Done.\n"
		;;
	bypass)
		checkPackageInstalled "dnsmasq-full"
		set_system_info
		disable_service
#		set_ssh_server
		insert_bypass_network_interface
		bypass_disable_dhcp_server
		bypass_firewall_interface
		bypass_bind_router_domain
		set_adblock_sources_list "lan"
		_greenH "Openwrt Vice-Router Bypass Mode Setting Done.\n"
		;;
	*)
		_yellow '\nPlease USE: "# sh set_op.sh [normal/bypass]"\n'
		_redH 'Done Nothing.\n\n'
		exit 1
		;;
esac

_greenH "Restarting DHCP...\n" &
/etc/init.d/odhcpd restart >/dev/null 2>&1
wait
sleep 2
_greenH "Restarting Firewall...\n" &
/etc/init.d/firewall restart >/dev/null 2>&1
wait
sleep 2
_greenH "Restarting Network...\n" &
/etc/init.d/network restart >/dev/null 2>&1
wait
sleep 6
_greenH "Rebooting System...\n"
sleep 2
reboot
exit 0

###############################################################################
## vim /etc/config/network  /etc/init.d/network restart  passwd root
#for i in `ls /sys/class/net | grep "eth"`; do echo "$i -> $(cat /sys/class/net/$i/address | tr '[a-z]' '[A-Z]')"; done
#bash: declare -A tt1; tt1=([mac]=12 [ip]=34 [port]=56); echo "${tt1[ip]}"

#/etc/init.d/network restart
#/etc/init.d/dnsmasq restart
#/etc/init.d/odhcpd restart
#/etc/init.d/firewall restart

#ethtool -s eth0 [speed 10|100|1000] [duplex half|full] [autoneg on|off]

