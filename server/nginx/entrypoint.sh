#!/bin/bash

VPNSET_DIR=/etc/vpn-set
NGINX_DATA_DIR=$VPNSET_DIR/nginx

if [ `grep -c stream.conf /etc/nginx/nginx.conf` == '0' ] ; then
    echo 'include /etc/nginx/stream.conf;' >> /etc/nginx/nginx.conf
fi

# Creating base data directory
if ! [ -d /etc/vpn-set/nginx ] ; then
    mkdir -p /etc/vpn-set/nginx
fi

if ! [ -e $NGINX_DATA_DIR/cert.pem ] ; then
        openssl req -x509 -newkey rsa:4096 -keyout $NGINX_DATA_DIR/key.pem -out $NGINX_DATA_DIR/cert.pem -nodes -subj '/CN=mydom.com/O=My Company Name LTD./C=US';
fi 


cat << _EOF_ > /etc/nginx/stream.conf 

stream {
    server {
        listen 1194 ssl; 
        proxy_pass openvpn:1194;
	    ssl_certificate     $NGINX_DATA_DIR/cert.pem;
        ssl_certificate_key $NGINX_DATA_DIR/key.pem;
    }
}


_EOF_

htpasswd -bc $NGINX_DATA_DIR/admin.htpasswd admin $ADMIN_PASSWORD

cat << _EOF_ > /etc/nginx/conf.d/default.conf

server {
	listen 443 ssl;

	root /var/www/;
	index index.html index.htm;
    

	server_name _;

    access_log  /var/log/nginx/host.access.log  main;

    auth_basic "Administrator’s Area";
    auth_basic_user_file $NGINX_DATA_DIR/admin.htpasswd;

    ssl_certificate     $NGINX_DATA_DIR/cert.pem;
    ssl_certificate_key $NGINX_DATA_DIR/key.pem;

    location /ovpn/ovpnmon/ {
        proxy_pass http://ovpnmon/;
    }

    location /ovpn/export/ {
        alias /etc/vpn-set/openvpn/export/;
        autoindex on;
    }

    location /ocserv/export/ {
        alias /etc/vpn-set/ocserv/export/;
        autoindex on;
    }

}

_EOF_


exec "$@"