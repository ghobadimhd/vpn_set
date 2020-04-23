#!/bin/bash

VPNSET_DIR=/etc/vpn-set
OCSERV_DATA_DIR=$VPNSET_DIR/ocserv
OCSERV_EASYRSA_DIR=$OCSERV_DATA_DIR/easyrsa
OCSERV_EXPORT_DIR=$OCSERV_DATA_DIR/export
OVPN_EASYRSA_DIR=$VPNSET_DIR/openvpn/easyrsa
OCPASSWD_DB=$OCSERV_DATA_DIR/ocpasswd.db

: ${OCSERV_MAX_CLIENT:= 1000 }
: ${OCSERV_MAX_SAME_CLIENT:= 1 }


# Creating base directoy
if ! [ -d $OCSERV_DATA_DIR ] ; then
    mkdir -p $OCSERV_DATA_DIR
fi

# Create export directories
if ! [ -a $OCSERV_EXPORT_DIR ] ; then
    mkdir -p $OCSERV_EXPORT_DIR
    chmod o=rx $OCSERV_EXPORT_DIR/
fi

for DIR in certs pkcs12 keys ; do
    if ! [ -a $OCSERV_EXPORT_DIR/$DIR ] ; then
        mkdir -p $OCSERV_EXPORT_DIR/$DIR
        chmod o=rx $OCSERV_EXPORT_DIR/$DIR
    fi
done

# Create easyrsa CA directory
if ! [ -a $OCSERV_EASYRSA_DIR ] ; then
    make-cadir $OCSERV_EASYRSA_DIR
    cd $OCSERV_EASYRSA_DIR
    cp openssl-1.0.0.cnf openssl.cnf
    . vars
    ./clean-all
    ./pkitool --initca
    ./pkitool --server ocserv
    #add read and execcute access to easyrsa directories so ocserv able to read crl.pem
    chmod o+rx $OCSERV_EASYRSA_DIR $OCSERV_EASYRSA_DIR/keys

    # creating empty crl.pem
    # set defaults
    export KEY_CN=""
    export KEY_OU=""
    export KEY_NAME=""

	# required due to hack in openssl.cnf that supports Subject Alternative Names
    export KEY_ALTNAMES=""
    openssl ca -gencrl -out $OCSERV_EASYRSA_DIR/keys/crl.pem -config $OCSERV_EASYRSA_DIR/openssl.cnf

    if ! [ -a $OCSERV_EASYRSA_DIR/keys/dh2048.pem ] ; then
        ./build-dh &> /dev/null
    fi
fi

# Create self sign ssl cert and key
if ! [ -e $OCSERV_DATA_DIR/cert.pem ] && [ ${OCSERV_ALT_AUTH:- "none" } == "none" ] ; then
        openssl req -x509 -newkey rsa:4096 -keyout $OCSERV_DATA_DIR/key.pem -out $OCSERV_DATA_DIR/cert.pem -nodes -subj '/CN=mydom.com/O=My Company Name LTD./C=US';
fi 

# Create test user
if ! [ -a $OCPASSWD_DB ] ; then
    echo -e 'test\ntest\n' | ocpasswd -c $OCPASSWD_DB test
    ln -s $OCPASSWD_DB /etc/ocserv/ocpasswd
fi
# Add nat
/sbin/iptables -t nat -A POSTROUTING -j MASQUERADE
iptables -A FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu

# Create Configuration file
cat <<-__EOF__ > /etc/ocserv/ocserv.conf
auth = "plain[passwd=$OCPASSWD_DB]"
tcp-port = 443
udp-port = 443
run-as-user = nobody
run-as-group = daemon
socket-file = /var/run/ocserv-socket
`case  ${OCSERV_ALT_AUTH:- "openvpn-cert" } in
    certificate)
        echo '# alternative authentication method'
        echo 'enable-auth = "certificate"'
        echo server-cert = $OCSERV_EASYRSA_DIR/keys/ocserv.crt
        echo server-key =  $OCSERV_EASYRSA_DIR/keys/ocserv.key
        echo ca-cert =  $OCSERV_EASYRSA_DIR/keys/ca.crt
        echo crl = $OCSERV_EASYRSA_DIR/keys/crl.pem
    ;;
    openvpn)
        echo '# alternative authentication method'
        echo 'enable-auth = "certificate"'
        echo server-cert = $OVPN_EASYRSA_DIR/keys/server.crt
        echo server-key =  $OVPN_EASYRSA_DIR/keys/server.key
        echo ca-cert =  $OVPN_EASYRSA_DIR/keys/ca.crt
        echo crl = $OVPN_EASYRSA_DIR/keys/crl.pem
    ;;
    none)
        echo server-cert = /etc/ssl/certs/ssl-cert-snakeoil.pem
        echo server-key = /etc/ssl/private/ssl-cert-snakeoil.key
        echo ca-cert = /etc/ssl/certs/ssl-cert-snakeoil.pem
    ;;
esac`
isolate-workers = true
max-clients = $OCSERV_MAX_CLIENT
max-same-clients = $OCSERV_MAX_SAME_CLIENT
keepalive = 32400
dpd = 90
mobile-dpd = 1800
try-mtu-discovery = false
cert-user-oid = 2.5.4.3
tls-priorities = "NORMAL:%SERVER_PRECEDENCE:%COMPAT:-VERS-SSL3.0"
auth-timeout = 240
min-reauth-time = 3
max-ban-score = 80
ban-reset-time = 300
cookie-timeout = 300
deny-roaming = false
rekey-time = 172800
rekey-method = ssl
use-utmp = true
use-occtl = true
pid-file = /var/run/ocserv.pid
device = vpns
predictable-ips = true
default-domain = example.com
ipv4-network = 10.10.10.0
ipv4-netmask = 255.255.255.0
dns = 8.8.8.8
ping-leases = false
route = default
no-route = 192.168.0.0/255.255.0.0
no-route = 10.0.0.0/255.0.0.0
no-route = 172.28.0.0/255.255.0.0
cisco-client-compat = true
dtls-legacy = true
compression = true

__EOF__


exec "$@"