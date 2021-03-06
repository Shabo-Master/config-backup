#!/bin/sh

##### THIS SCRIPT IS NOW OBSELETE. USE ndsend.sh INSTEAD #####

# The sh_tty switch upstream, coming from RJ Networks,
# does not perform ND correctly. It relies on DAD to discover
# link-layer addr for an IPv6 address, and it will "validate" this MAC-IP
# pair by sending NS with explicit MAC and IP as destination & target,
# which makes it impossible to use NDP relay.
# Furthermore, when a packet with unknown destination address comes from outside,
# it does NOT send any NS to discover the link-layer address. Instead,
# it just drops the packet! I've never seen such a router in my life.
#
# Chances are that the switch requires a NS targeting at the address,
# or a NA originating by the the address (not necessarily a complete DAD
# procedure), before it recognizes the address.
# But DAD is the easiest way to trigger the dumb switch.
#
# This script will only deal with DAD and 1st time of NS.
# You need npd6 with ignroeLocal = false to deal with later NSes.

# This will be concatenated with number 0~9 to form a valid address, be careful about the format
IPV6_PREFIX="2001:250:4000:8210:2333:beef:2333:100"
WAN6_IFNAME=eth1
PATH=$PATH:/usr/bin:/usr/sbin

for i in `seq 0 9`; do
	# These are the addresses being used in LAN.
	# Add them on WAN interface to start DAD procedure so that the upstream
	# switch recognizes them.
	ip -6 addr add $IPV6_PREFIX$i/128 dev $WAN6_IFNAME
#	sleep 5
	ping6 240c::6666 -c 5
	ip -6 addr del $IPV6_PREFIX$i/128 dev $WAN6_IFNAME
done

# Wait for DAD and RJ's NS check finish
#sleep 25

#for i in `seq 0 9`; do
	# The switch knows the addresses now.
#	ip -6 addr del $IPV6_PREFIX$i/128 dev $WAN6_IFNAME
#done

logger "refresh6: DAD and NS finished for LAN"
