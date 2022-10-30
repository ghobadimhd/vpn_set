#!/bin/bash

VPNSET_DIR=/etc/vpnset
OCSERV_CONF_DIR=$VPNSET_DIR/ocserv
EASYRSA_DIR=$VPNSET_DIR/easyrsa
OCSERV_EXPORT_DIR=$OCSERV_CONF_DIR/export
OCPASSWD_DB=$OCSERV_CONF_DIR/ocpasswd.db

CERT_NAME=vpnset-server

: ${OCSERV_MAX_CLIENT:= 1000 }
: ${OCSERV_MAX_SAME_CLIENT:= 1 }

if ! [ -e ~/.rnd ] ; then
    openssl rand -out ~/.rnd 512
fi

# Creating base directoy
if ! [ -d $OCSERV_CONF_DIR ] ; then
    mkdir -p $OCSERV_CONF_DIR
fi

# Create test user
if ! [ -a $OCPASSWD_DB ] ; then
    echo -e 'test\nUfcejulefKipDafVos3Quoarjofmaykyechkaqua\n' | ocpasswd -c $OCPASSWD_DB test
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
# alternative authentication method
enable-auth = "certificate"
server-cert = $OCSERV_CONF_DIR/$CERT_NAME.crt
server-key =  $OCSERV_CONF_DIR/$CERT_NAME.key
ca-cert =  $EASYRSA_DIR/pki/ca.crt
crl = $EASYRSA_DIR/pki/crl.pem
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
device = ocserv
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