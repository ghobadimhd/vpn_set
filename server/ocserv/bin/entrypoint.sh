#!/bin/bash

VPNSET_DIR=/etc/vpn-set
OCSERV_DATA_DIR=$VPNSET_DIR/ocserv
OCPASSWD_DB=$OCSERV_DATA_DIR/ocpasswd.db

# Creating base directoy
if ! [ -d $OCSERV_DATA_DIR ] ; then
    mkdir -p $OCSERV_DATA_DIR
fi

# Create self sign ssl cert and key
if ! [ -e $OCSERV_DATA_DIR/cert.pem ] ; then
        openssl req -x509 -newkey rsa:4096 -keyout $OCSERV_DATA_DIR/key.pem -out $OCSERV_DATA_DIR/cert.pem -nodes -subj '/CN=mydom.com/O=My Company Name LTD./C=US';
fi 

# Create test user
if ! [ -a $OCPASSWD_DB ] ; then
    echo -e 'test\ntest\n' | ocpasswd -c $OCPASSWD_DB test
fi
# Add nat
/sbin/iptables -t nat -A POSTROUTING -j MASQUERADE
iptables -A FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu

exec "$@"