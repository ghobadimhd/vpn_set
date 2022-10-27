#!/bin/bash


VPNSET_DIR=/etc/vpnset
OPENVPN_CONF_DIR=$VPNSET_DIR/openvpn
OPENVPN_DATA_DIR=$VPNSET_DIR/openvpn
OPENVPN_EXPORT_DIR=$OPENVPN_DATA_DIR/export
EASYRSA_DIR=$OPENVPN_DATA_DIR/easyrsa

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
if ! [ -a $EASYRSA_DIR ] ; then
    mkdir $EASYRSA_DIR
    tar xf /EasyRSA-3.1.1.tgz -C /etc/vpnset/openvpn/easyrsa/  --strip-components=1
    cd $EASYRSA_DIR
    if ! [ -a pki ] ; then  
        ./easyrsa init-pki ;
        openssl rand 40 > pki/.rnd
    fi
    if ! [ -a pki/ca.crt ]; then
        EASYRSA_REQ_CN=CA ./easyrsa build-ca nopass
    fi
    if ! [ -a pki/issued/ov-server.crt ]; then
        echo "Create server"
        ./easyrsa build-server-full ov-server nopass 2> /var/log/ovctl.log > /var/log/ovctl.log
    fi

    # creating empty crl.pem
    # set defaults
    echo "Generate CRL" 
    ./easyrsa gen-crl 2> /var/log/ovctl.log > /var/log/ovctl.log

    if ! [ -a $EASYRSA_DIR/pki/dh.pem ] ; then
        ./easyrsa gen-dh &> /dev/null
    fi
    #add read and execcute access to easyrsa directories so openvpn able to read crl.pem
    chmod o+rx $EASYRSA_DIR $EASYRSA_DIR/pki $EASYRSA_DIR/pki/crl.pem $EASYRSA_DIR/pki/dh.pem
fi




# Create openvpn user
id openvpn || adduser --home /etc/vpnset/openvpn --shell /usr/sbin/nologin --disabled-login openvpn --system --group

cp $EASYRSA_DIR/pki/issued/ov-server.crt $EASYRSA_DIR/pki/private/ov-server.key $OPENVPN_CONF_DIR/
chown openvpn:openvpn $VPNSET_DIR/openvpn/ov-server.crt $VPNSET_DIR/openvpn/ov-server.key
chmod u=rx $VPNSET_DIR/openvpn/ov-server.crt $VPNSET_DIR/openvpn/ov-server.key


# A iptable MASQUERADE NAT rule
iptables -t nat -A POSTROUTING -s 10.10.20.0/24 -o ovpntun -j MASQUERADE


exec "$@"
