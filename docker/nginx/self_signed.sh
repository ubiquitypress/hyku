#!/bin/bash
# Generate SSL certificate if none exists
if ([ ! -f /etc/selfsigned/server.key ] || [ ! -f /etc/selfsigned/server.crt ]); then
  echo "Creating self-signed certificates"
  openssl genrsa -des3 -passout pass:averylongpassword -out /etc/selfsigned/server.pass.key 2048
  openssl rsa -passin pass:averylongpassword -in /etc/selfsigned/server.pass.key -out /etc/selfsigned/server.key
  rm /etc/selfsigned/server.pass.key
  openssl req -new -key /etc/selfsigned/server.key -out /etc/selfsigned/server.csr -subj "/C=GB/ST=London/L=London/O=UP/OU=UP/CN=$DOMAIN"
  openssl x509 -req -sha256 -days 300065 -in /etc/selfsigned/server.csr -signkey /etc/selfsigned/server.key -out /etc/selfsigned/server.crt
else
  echo "Using existing self-signed certificates"
fi

# Substitute environment variables in the Nginx config file and copy it
envsubst '$$DOMAIN $$SUBDOMAIN' < $NGINX_SS_CONF > /etc/nginx/conf.d/default.conf
