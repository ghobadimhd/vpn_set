#!/bin/bash


if [ `grep -c stream.conf /etc/nginx/nginx.conf` == '0' ] ; then
    echo 'include /etc/nginx/stream.conf;' >> /etc/nginx/nginx.conf
fi

if [ -e  /etc/nginx/conf.d/default.conf ] ; then
   rm /etc/nginx/conf.d/default.conf
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

        server {
                listen 80;
                proxy_pass $SERVER_ADDRESS:$HTTP_PORT;
        }

}

_EOF_

exec "$@"