#!/bin/bash


VPNSET_DIR=/etc/vpnset
OPENVPN_CONF_DIR=$VPNSET_DIR/openvpn
OPENVPN_DATA_DIR=$VPNSET_DIR/openvpn
OPENVPN_EXPORT_DIR=$OPENVPN_DATA_DIR/export

CERT_NAME=vpnset-server

EASYRSA_DIR=$VPNSET_DIR/easyrsa

export EASYRSA_BATCH=1

# Create Server Config
if ! [ -a $OPENVPN_DATA_DIR/openvpn.conf ] ; then
    cp /client.conf.tpl $OPENVPN_DATA_DIR/client.conf.tpl
fi

# Craete client configuration file
cat << _EOF_ > /etc/vpnset/openvpn/client.conf
`cat /client.conf.tpl`
`echo remote ${BRIDGE_ADDRESS:-localhost}`
`echo proto ${OVPN_PROTOCOL:-tcp}`
`echo port ${BRIDGE_OVPN_PORT:-2443}`

_EOF_


# Create Server Config
if ! [ -a $OPENVPN_DATA_DIR/openvpn.conf ] ; then
    cp /openvpn.conf.tpl $OPENVPN_DATA_DIR/openvpn.conf
fi

# Creating base data directoy
if ! [ -a $OPENVPN_DATA_DIR ] ; then
    mkdir -p $OPENVPN_DATA_DIR
fi

# Create openvpn user
id openvpn || adduser --home /etc/vpnset/openvpn --shell /usr/sbin/nologin --disabled-login openvpn --system --group

# cp $EASYRSA_DIR/pki/issued/$CERT_NAME.crt $EASYRSA_DIR/pki/private/$CERT_NAME.key $OPENVPN_CONF_DIR/
chown openvpn:openvpn $VPNSET_DIR/openvpn/$CERT_NAME.crt $VPNSET_DIR/openvpn/$CERT_NAME.key
# chmod u=rx $VPNSET_DIR/openvpn/$CERT_NAME.crt $VPNSET_DIR/openvpn/$CERT_NAME.key


# A iptable MASQUERADE NAT rule
iptables -t nat -A POSTROUTING -s 10.10.20.0/24 -o ovpntun -j MASQUERADE


exec "$@"
