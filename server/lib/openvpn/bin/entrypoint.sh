#!/bin/bash

VPNSET_DIR=/etc/vpnset
OPENVPN_DATA_DIR=$VPNSET_DIR/openvpn
CERT_NAME=vpnset-server

# Creating base data directoy
if ! [ -a $OPENVPN_DATA_DIR ] ; then
    mkdir -p $OPENVPN_DATA_DIR
fi

# Create Server Config
if ! [ -a $OPENVPN_DATA_DIR/openvpn.conf ] ; then
    cp /openvpn.conf.tpl $OPENVPN_DATA_DIR/openvpn.conf
fi

# Create openvpn user
id openvpn || adduser --home /etc/vpnset/openvpn --shell /usr/sbin/nologin --disabled-login openvpn --system --group

#FIXME: This should handled in easyrsa
chown openvpn:openvpn $VPNSET_DIR/openvpn/$CERT_NAME.crt $VPNSET_DIR/openvpn/$CERT_NAME.key

# A iptable MASQUERADE NAT rule
iptables -t nat -A POSTROUTING -s 10.10.20.0/24 -o ovpntun -j MASQUERADE


exec "$@"
