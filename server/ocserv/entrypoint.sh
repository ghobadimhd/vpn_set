#!/bin/bash


# Create test user
if ! [ -a /etc/ocserv/ocpasswd ] ; then
    echo -e 'test\ntest\n' | ocpasswd test
fi
# Add nat
/sbin/iptables -t nat -A POSTROUTING -j MASQUERADE
iptables -A FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu

exec "$@"