FROM ubuntu:focal

RUN apt update ; apt install -y dante-server ; apt clean ; mkdir /data ; touch /data/sockd.passwd
ADD ./danted/danted.conf /config/danted.conf
ADD ./danted/sockd /etc/pam.d/sockd

CMD ["/usr/sbin/danted", "-f", "/config/danted.conf"]