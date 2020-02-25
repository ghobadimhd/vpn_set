FROM ubuntu
RUN    apt update ; apt install -y ca-certificates ocserv less iptables

COPY ocserv.conf /etc/ocserv/ocserv.conf
COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["bash", "/entrypoint.sh"]

CMD /usr/sbin/ocserv -f -c /etc/ocserv/ocserv.conf