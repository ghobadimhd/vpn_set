#!/bin/bash


if [ `grep -c stream.conf /etc/nginx/nginx.conf` == '0' ] ; then
    echo 'include /etc/nginx/stream.conf;' >> /etc/nginx/nginx.conf
fi


cat << _EOF_ > /etc/nginx/stream.conf 

stream {
        server {
                listen 4433 ;
                proxy_pass $SERVER_ADDRESS:$OCSERV_PORT;
        }
        server {
                listen 4433 udp ;
                proxy_pass $SERVER_ADDRESS:$OCSERV_PORT;
        }
        server {
                listen 1194;
                proxy_pass $SERVER_ADDRESS:$OVPN_PORT;
                proxy_ssl on ;
        }

}

_EOF_

exec "$@"