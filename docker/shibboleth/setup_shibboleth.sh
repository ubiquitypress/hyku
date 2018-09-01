#!/bin/bash
echo "Setting up shibboleth"
if [ -f /data/shibboleth/sp-cert.pem ] && \
   [ -f /data/shibboleth/sp-key.pem ]
then
  echo "Copying Shib key files"
  cp /data/shibboleth/sp-cert.pem /etc/shibboleth/
  cp /data/shibboleth/sp-key.pem /etc/shibboleth/
else
  echo "Starting shib keygen"
  /usr/sbin/shib-keygen
  echo "Saving shib key files"
  cp /etc/shibboleth/sp-cert.pem /data/shibboleth/
  cp /etc/shibboleth/sp-key.pem /data/shibboleth/
fi
SUBDOMAIN="$SHIBBOLETH_TENANT"."$DOMAIN"
envsubst '$SUBDOMAIN' < /data/shibboleth/shibboleth2.xml > /etc/shibboleth/shibboleth2.xml
