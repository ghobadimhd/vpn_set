#!/bin/bash


if [ `grep -c stream.conf /etc/nginx/nginx.conf` == '0' ] ; then
    echo 'include /etc/nginx/stream.conf;' >> /etc/nginx/nginx.conf
fi

if ! [ -e /etc/ssl/cert.pem ] ; then
        openssl req -x509 -newkey rsa:4096 -keyout /etc/ssl/key.pem -out /etc/ssl/cert.pem -nodes -subj '/CN=mydom.com/O=My Company Name LTD./C=US';
fi 


cat << _EOF_ > /etc/nginx/stream.conf 

stream {
    server {
        listen 1194 ssl; 
        proxy_pass openvpn:1194;
	    ssl_certificate     /etc/ssl/cert.pem;
        ssl_certificate_key /etc/ssl/key.pem;
    }
}


_EOF_

exec "$@"