FROM ubuntu:bionic
RUN    apt update ; apt install -y ca-certificates ocserv less iptables easy-rsa ; apt clean

COPY ./bin/ /usr/local/bin/
RUN chmod -R a+x /usr/local/bin/
ENTRYPOINT ["bash", "/usr/local/bin/entrypoint.sh"]

CMD /usr/sbin/ocserv -fd 10 -c /etc/ocserv/ocserv.conf