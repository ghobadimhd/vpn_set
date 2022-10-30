FROM ubuntu:focal
RUN apt update ; apt install -y  ca-certificates ocserv less iptables ; \
    wget https://github.com/OpenVPN/easy-rsa/releases/download/v3.1.1/EasyRSA-3.1.1.tgz -O /EasyRSA-3.1.1.tgz ; \
    apt clean

COPY ./ocserv/bin/ /usr/local/bin/
COPY ./bin/ /usr/local/bin/
RUN chmod -R a+x /usr/local/bin/
ENTRYPOINT ["bash", "/usr/local/bin/entrypoint.sh"]

CMD /usr/sbin/ocserv -fd 10 -c /etc/ocserv/ocserv.conf