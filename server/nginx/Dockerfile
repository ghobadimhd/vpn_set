FROM nginx 

RUN apt update ; apt install openssl -y ; \
    openssl req -x509 -newkey rsa:4096 -keyout /etc/ssl/key.pem -out /etc/ssl/cert.pem -nodes -subj '/CN=mydom.com/O=My Company Name LTD./C=US';

COPY entrypoint.sh /usr/local/bin/
RUN chmod -R a+x /usr/local/bin/
ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]

CMD ["nginx", "-g", "daemon off;"]

