#!/bin/sh
echo "Getting certificate";

# function to add domains
add_domains() {
  domains="$DOMAIN"
  for i in $TENANTS;
  do
    domains="$domains,$i.$DOMAIN";
  done
  echo "$domains";
}

domains=$(add_domains);
echo ${domains};

test_cert="";
if [ "$USE_TEST_CERT" = true ] ; then
    test_cert="--test-cert";
fi

certbot certonly -n --agree-tos --no-eff-email --keep $test_cert \
  --email "$EMAIL" \
  --webroot --webroot-path=/data/letsencrypt \
  -d "$domains"

# Installing and managing certificate
if [ -f /etc/letsencrypt/live/$DOMAIN/fullchain.pem ] && \
   [ -f /etc/letsencrypt/live/$DOMAIN/privkey.pem ] && \
   [ -f /etc/letsencrypt/live/$DOMAIN/chain.pem ]
then
  # Copy Let's Encrypt nginx conf files
  #   after replacing domains with their values
  echo "Copying Let's Encrypt nginx conf"
  envsubst '$$DOMAIN $$SUBDOMAIN' < $NGINX_CA_CONF > /etc/nginx/conf.d/default.conf
  envsubst '$DOMAIN' < /data/ssl-ca > /etc/nginx/include.d/ssl-ca

  # Reload nginx
  echo "Reload nginx"
  /usr/sbin/nginx -s reload

  # Start cron
  echo "Starting cron"
  /usr/sbin/cron

  # Set cron for renewing certificates
  echo "Setting crontab for renewing certificates"
  crontab /data/cron_data
else
  echo "Let's Encrypt certificates not available"
fi
