#!/bin/bash

[ -z "${DOMAINS}" ] && DOMAINS="trillian-ilo.fragilegeek.com"
[ -z "${LE_EMAIL}" ] && LE_EMAIL="mattsday@gmail.com"
[ -z "${CERT_NAME}" ] && CERT_NAME=trillian-ilo
[ -z "${EXPIRY_THRESHOLD}" ] && EXPIRY_THRESHOLD=1814400
[ -z "${OUTPUT_FULL_CHAIN}" ] && OUTPUT_FULL_CHAIN=/etc/letsencrypt/live/"${CERT_NAME}"/fullchain.pem
[ -z "${OUTPUT_SECRET}" ] && OUTPUT_SECRET=/etc/letsencrypt/live/"${CERT_NAME}"/privkey.pem
[ -z "${GCP_DNS_WAIT}" ] && GCP_DNS_WAIT=120
[ -z "${GCP_CREDENTIALS_FILE}" ] && GCP_CREDENTIALS_FILE="/sa.json"

# Generate CSR request (already done)
#hpilo_cli -l Administrator -p 72TDGQ8T 10.86.0.12 certificate_signing_request country= state= locality= organization= organizational_unit= common_name=trillian-ilo.fragilegeek.com

# Check existing cert
if [ -f "${OUTPUT_FULL_CHAIN}" ]; then
    if sudo openssl x509 -checkend "${EXPIRY_THRESHOLD}" -noout -in "${OUTPUT_FULL_CHAIN}" >/dev/null 2>&1; then
        echo Cert not expiring
        exit 0
    fi
fi

echo Cert will expire or does not exist

if ! sudo certbot certonly -n --agree-tos --email ${LE_EMAIL} \
    --dns-google-propagation-seconds ${GCP_DNS_WAIT} \
    --dns-google --dns-google-credentials ${GCP_CREDENTIALS_FILE} \
    --cert-name "${CERT_NAME}" \
    -d "${DOMAINS}" \
    --cert-path ./; then
    echo Error getting certificate
    exit 1
fi
