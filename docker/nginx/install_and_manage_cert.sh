#!/bin/bash
if [ -f /etc/letsencrypt/live/$DOMAIN/fullchain.pem ] && \
   [ -f /etc/letsencrypt/live/$DOMAIN/privkey.pem ] && \
   [ -f /etc/letsencrypt/live/$DOMAIN/chain.pem ]
then
  # Let's Encrypt certificates exist

  # Copy Let's Encrypt nginx conf files
  #   after replacing domains with their values (stored as environment variables)
  echo "Copying Let's Encrypt nginx conf"
  if [ "$USE_SHIBBOLETH" = true ] ; then
    SUBDOMAIN="$SHIBBOLETH_TENANT"."$DOMAIN";
    envsubst '$SUBDOMAIN1' < /data/shibboleth2.xml > /etc/shibboleth/shibboleth2.xml;
    envsubst '$$DOMAIN $$SUBDOMAIN1' < /data/nginx_ca_shib.conf > /etc/nginx/conf.d/default.conf;
  else
    envsubst '$DOMAIN' < /data/nginx_ca.conf > /etc/nginx/conf.d/default.conf;
  fi
  envsubst '$DOMAIN' < /data/ssl-ca > /etc/nginx/include.d/ssl-ca

  # Reload nginx
  echo "Reload nginx"
  /usr/sbin/nginx -s reload

  # Set cron for renewing certificates
  echo "Setting crontab for renewing certificates"
  crontab /data/cron_data
fi
