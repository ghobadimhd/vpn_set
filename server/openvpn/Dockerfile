FROM ubuntu:focal

RUN apt update ; apt install --no-install-recommends -y openvpn less iptables wget ca-certificates ; \
    wget https://github.com/OpenVPN/easy-rsa/releases/download/v3.1.1/EasyRSA-3.1.1.tgz -O /EasyRSA-3.1.1.tgz ;
COPY openvpn.conf /openvpn.conf.tpl
COPY openvpn-client-template.conf /client.conf.tpl
COPY ./bin/ /usr/local/bin/

RUN chmod -R a+x /usr/local/bin/

ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]

CMD ["/usr/sbin/openvpn", "/etc/vpnset/openvpn/openvpn.conf"]
# CMD bash -c "tail -f /dev/null"

