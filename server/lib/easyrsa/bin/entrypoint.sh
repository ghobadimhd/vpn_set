#!/bin/bash

VPNSET_DIR=/etc/vpnset
VPNSET_EXPORT_DIR=$VPNSET_DIR/export

CERT_NAME=vpnset-server

EASYRSA_DIR=$VPNSET_DIR/easyrsa

export EASYRSA_BATCH=1

# Create easyrsa CA directory
certctl2 init-pki
certctl2 create-server $CERT_NAME

# Create export directories
if ! [ -a $VPNSET_EXPORT_DIR ] ; then
    mkdir -p $VPNSET_EXPORT_DIR
    chmod o=rx $VPNSET_EXPORT_DIR/
fi

for DIR in certs pkcs12 keys profiles ; do
    if ! [ -a $VPNSET_EXPORT_DIR/$DIR ] ; then
        mkdir -p $VPNSET_EXPORT_DIR/$DIR
        chmod o=rx $VPNSET_EXPORT_DIR/$DIR
    fi
done

for dirname in openvpn ocserv traefik ; do 
    if ! [ -a $VPNSET_DIR/$dirname ] ; then
        mkdir $VPNSET_DIR/$dirname
    fi

    cp $EASYRSA_DIR/pki/issued/$CERT_NAME.crt $EASYRSA_DIR/pki/private/$CERT_NAME.key $VPNSET_DIR/$dirname/
    chmod uo=rx $VPNSET_DIR/$dirname/$CERT_NAME.crt $VPNSET_DIR/$dirname/$CERT_NAME.key
done

[ -a $EASYRSA_DIR/client.conf.tpl ] || cp /client.conf.tpl $EASYRSA_DIR/client.conf.tpl

if ! [ -a $VPNSET_DIR/danted ] ; then
    mkdir $VPNSET_DIR/danted
    touch $VPNSET_DIR/danted/sockd.passwd
    ln -s data
fi

if ! [ -a $VPNSET_DIR/traefik/passwd ] ; then 
    # admin:ChangeMeNoWplease
    echo -n 'admin:$apr1$RW4ddMWw$KQfuwcnLySJIfhIwFIuqF1' > $VPNSET_DIR/traefik/passwd ;
fi

exec "$@"
