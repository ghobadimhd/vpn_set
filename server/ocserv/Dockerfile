FROM ubuntu
RUN    apt update ; apt install -y ca-certificates ocserv less iptables

COPY ocserv.conf /etc/ocserv/ocserv.conf
COPY ./bin/ /usr/local/bin/
RUN chmod -R a+x /usr/local/bin/
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["bash", "/entrypoint.sh"]

CMD /usr/sbin/ocserv -f -c /etc/ocserv/ocserv.conf