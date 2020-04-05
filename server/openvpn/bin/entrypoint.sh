#!/bin/bash

OPENVPN_CONF_DIR=/etc/openvpn
VPNSET_DIR=/etc/vpn-set
OPENVPN_DATA_DIR=$VPNSET_DIR/openvpn
EASYRSA_DIR=$OPENVPN_DATA_DIR/easyrsa

# Craete client configuration file
cat << _EOF_ > /etc/openvpn/client.conf
`cat /etc/openvpn/client.conf.tpl`
`echo remote $BRIDGE_ADDRESS`
`echo proto $OVPN_PROTOCOL `
`echo port $BRIDGE_OVPN_PORT`

_EOF_


# Create Server Config
cat << _EOF_ > $OPENVPN_CONF_DIR/openvpn.conf
management 0.0.0.0 5555
`echo proto $OVPN_PROTOCOL `
`echo port 1194`
`cat $OPENVPN_CONF_DIR/openvpn.conf.tpl`

_EOF_


# Creating base data directoy
if ! [ -d $OPENVPN_DATA_DIR ] ; then
    mkdir -p $OPENVPN_DATA_DIR
fi

# Create easyrsa CA directory
if ! [ -a $EASYRSA_DIR ] ; then
    make-cadir $EASYRSA_DIR
    cd $EASYRSA_DIR
    cp openssl-1.0.0.cnf openssl.cnf
    . vars
    ./clean-all
    ./pkitool --initca
    ./pkitool --server server
    #add read and execcute access to easyrsa directories so openvpn able to read crl.pem
    chmod o+rw $EASYRSA_DIR $EASYRSA_DIR/keys

    # creating empty crl.pem
    # set defaults
    export KEY_CN=""
    export KEY_OU=""
    export KEY_NAME=""

	# required due to hack in openssl.cnf that supports Subject Alternative Names
    export KEY_ALTNAMES=""
    openssl ca -gencrl -out $EASYRSA_DIR/keys/crl.pem -config $EASYRSA_DIR/openssl.cnf

    if ! [ -a $EASYRSA_DIR/keys/dh2048.pem ] ; then
        ./build-dh &> /dev/null
    fi
fi




# A iptable MASQUERADE NAT rule
iptables -t nat -A POSTROUTING -j MASQUERADE


exec "$@"
