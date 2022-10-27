#!/bin/bash


VPNSET_DIR=/etc/vpnset
OPENVPN_CONF_DIR=$VPNSET_DIR/openvpn
OPENVPN_DATA_DIR=$VPNSET_DIR/openvpn
OPENVPN_EXPORT_DIR=$OPENVPN_DATA_DIR/export

OVPN_CERT_NAME=ov-server

EASYRSA_DIR=$VPNSET_DIR/easyrsa

export EASYRSA_BATCH=1

# Craete client configuration file
cat << _EOF_ > /etc/vpnset/openvpn/client.conf
`cat /client.conf.tpl`
`echo remote $BRIDGE_ADDRESS`
`echo proto $OVPN_PROTOCOL `
`echo port $BRIDGE_OVPN_PORT`

_EOF_


# Create Server Config
cat << _EOF_ > $OPENVPN_DATA_DIR/openvpn.conf
management 0.0.0.0 5555
`echo proto $OVPN_PROTOCOL `
`echo port 1194`
`cat /openvpn.conf.tpl`

_EOF_


# Creating base data directoy
if ! [ -a $OPENVPN_DATA_DIR ] ; then
    mkdir -p $OPENVPN_DATA_DIR
fi

# Create export directories
if ! [ -a $OPENVPN_EXPORT_DIR ] ; then
    mkdir -p $OPENVPN_EXPORT_DIR
    chmod o=rx $OPENVPN_EXPORT_DIR
fi
for DIR in certs profiles keys ; do
    if ! [ -a $OPENVPN_EXPORT_DIR/$DIR ] ; then
        mkdir -p $OPENVPN_EXPORT_DIR/$DIR
        chmod o=rx $OPENVPN_EXPORT_DIR/$DIR
    fi
done

# Create easyrsa CA directory
ovctl init-pki
ovctl server-create $OVPN_CERT_NAME

# Create openvpn user
id openvpn || adduser --home /etc/vpnset/openvpn --shell /usr/sbin/nologin --disabled-login openvpn --system --group

cp $EASYRSA_DIR/pki/issued/$OVPN_CERT_NAME.crt $EASYRSA_DIR/pki/private/$OVPN_CERT_NAME.key $OPENVPN_CONF_DIR/
chown openvpn:openvpn $VPNSET_DIR/openvpn/$OVPN_CERT_NAME.crt $VPNSET_DIR/openvpn/$OVPN_CERT_NAME.key
chmod u=rx $VPNSET_DIR/openvpn/$OVPN_CERT_NAME.crt $VPNSET_DIR/openvpn/$OVPN_CERT_NAME.key


# A iptable MASQUERADE NAT rule
iptables -t nat -A POSTROUTING -s 10.10.20.0/24 -o ovpntun -j MASQUERADE


exec "$@"
