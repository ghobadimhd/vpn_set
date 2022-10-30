FROM ubuntu:focal

RUN apt update ; apt install --no-install-recommends -y less wget ca-certificates apache2-utils ; \
    wget https://github.com/OpenVPN/easy-rsa/releases/download/v3.1.1/EasyRSA-3.1.1.tgz -O /EasyRSA-3.1.1.tgz ;

COPY ./easyrsa/bin/ /usr/local/bin/
COPY ./bin/ /usr/local/bin/

ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]

CMD ["/bin/bash", "-c", "tail -f"]