FROM ubuntu

RUN apt update ; apt install -y openvpn less iptables easy-rsa ;

COPY openvpn.conf /etc/openvpn/openvpn.conf.tpl
COPY openvpn-client-template.conf /etc/openvpn/client.conf.tpl
COPY ./bin/ /usr/local/bin/

RUN chmod -R a+x /usr/local/bin/

ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]

CMD ["/usr/sbin/openvpn", "/etc/openvpn/openvpn.conf"]
# CMD bash -c "tail -f /dev/null"

