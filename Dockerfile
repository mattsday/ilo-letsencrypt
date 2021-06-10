FROM debian:buster
RUN apt update && apt -y full-upgrade && apt -y install git python3-pip python3-certbot python3-certbot-dns-google
RUN pip3 install python-hpilo
COPY ilo.sh /ilo.sh
COPY cert.csr /cert.csr 
COPY sa.json /sa.json

