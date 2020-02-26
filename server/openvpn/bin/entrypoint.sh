#!/bin/bash

# Craete client configuration file
cat << _EOF_ > /etc/openvpn/client.conf
`cat /etc/openvpn/client.conf.tpl`
`echo remote $BRIDGE_ADDRESS`
`echo proto $OVPN_PROTOCOL `
`echo port $BRIDGE_OVPN_PORT`

_EOF_


# Create Server Config
cat << _EOF_ > /etc/openvpn/openvpn.conf
management 0.0.0.0 5555
`echo proto $OVPN_PROTOCOL `
`echo port 1194`
`cat /etc/openvpn/openvpn.conf.tpl`

_EOF_

# Create server and server config
if ! [ -a /etc/openvpn/easyrsa ] ; then
    make-cadir /etc/openvpn/easyrsa
    cd /etc/openvpn/easyrsa
    cp openssl-1.0.0.cnf openssl.cnf
    . vars
    ./clean-all
    ./pkitool --initca
    ./pkitool --server server

    # creating empty crl.pem 
    # set defaults
    export KEY_CN=""
    export KEY_OU=""
    export KEY_NAME=""

	# required due to hack in openssl.cnf that supports Subject Alternative Names
    export KEY_ALTNAMES=""
    openssl ca -gencrl -out /etc/openvpn/easyrsa/keys/crl.pem -config /etc/openvpn/easyrsa/openssl.cnf 

fi


if ! [ -a /etc/openvpn/easyrsa/keys/dh2048.pem ] ; then 
    openssl dhparam  -out /etc/openvpn/easyrsa/keys/dh2048.pem 2048
fi 

# A iptable MASQUERADE NAT rule
iptables -t nat -A POSTROUTING -j MASQUERADE


exec "$@"
