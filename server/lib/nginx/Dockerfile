FROM nginx 

RUN apt update ; apt install -y openssl apache2-utils
COPY nginx/entrypoint.sh /usr/local/bin/
RUN chmod -R a+x /usr/local/bin/
ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]

CMD ["nginx", "-g", "daemon off;"]

