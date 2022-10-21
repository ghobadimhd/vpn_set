VPN SET
=======

This is simple project to setup multiple VPN servers.

# Design

![Design](https://github.com/ghobadimhd/vpn_set/blob/master/assets/design.png)

# Requirments

* ubuntu
* [Docker](https://https://docs.docker.com/engine/install/ubuntu/)
* docker-compose

  ```bash
  wget https://github.com/docker/compose/releases/download/v2.11.0/docker-compose-linux-x86_64 -O /usr/local/bin/docker-compose ; chmod u+x /usr/local/bin/docker-compose
  ```


# Installation

## Set up Foriegn/Edge Server

1. Clone repository on Edge Server

   ```bash
   cd /opt
   git clone https://github.com/ghobadimhd/vpn_set.git
   cd vpn_set
   ```

2. Create the *vpn.env* from sample

   ```bash
   cp vpn.env-sample vpn.env
   ```

3. Change the SERVER_ADDRESS and BRIDGE_ADDRESS to Your Servers addresses.
**You must also change the ADMIN_PASSWORD too.**

4. Run Edge services

   ```bash 
   cd server
   docker-compose up -d 
   ```

## Set up Domestic/Bridge Server

1. Proceed 1 to 3 from last section

2. Run bridge Services

   ```bash 
   cd bridge
   docker-compose up -d 
   ```

# Usage

**TODO

## Openvpn

***TODO 

```bash 
docker exec openvpn ovctl -h 
addprofile, list, and print config file

sub commands: 
    list                       print list of existing client certificates
    addprofile CLIENTNAME         create new client certificate 
    addprofile_bulk PREFIX COUNT  create multiple client certificate
    getprofile CLIENTNAME      print existing client profile
    getcert CLIENTNAME         print existing client certificate
    getkey CLIENTNAME          print existing client private key
    revoke CLIENTNAME          revoke client certificate
    gencrl [CRL_EXPIRE_DAYS default is 365]          revoke client certificate
    export [-k] [-c] [-p]      revoke client certificate
    help                       print this message

```

## Openconnect

**TODO

### Client Certificate

```bash 
docker exec ocserv certctl -h 
addcert, addcert_bulk, list, and print config file

sub commands: 
    list                       print list of existing client certificates
    addcert CLIENTNAME         create new client certificate 
    addcert_bulk PREFIX COUNT  create multiple client certificate
    getpkcs12 CLIENTNAME       print existing client pkcs12 certificate
    getcert CLIENTNAME         print existing client certificate
    getkey CLIENTNAME          print existing client private key
    revoke CLIENTNAME          revoke client certificate
    gencrl [CRL_EXPIRE_DAYS default is 365]          revoke client certificate
    export [-k] [-c] [-p]      revoke client certificate
    help                       print this message
```