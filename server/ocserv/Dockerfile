FROM ubuntu
RUN    apt update ; apt install -y ca-certificates ocserv less iptables

COPY ./bin/ /usr/local/bin/
RUN chmod -R a+x /usr/local/bin/
ENTRYPOINT ["bash", "/usr/local/bin/entrypoint.sh"]

CMD /usr/sbin/ocserv -f -c /etc/ocserv/ocserv.conf