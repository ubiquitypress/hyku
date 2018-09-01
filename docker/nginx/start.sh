#!/bin/bash
source /data/web_server_env.sh
export SUBDOMAIN="$SHIBBOLETH_TENANT"."$DOMAIN";
if [ "$USE_SHIBBOLETH" = true ] ; then
  export NGINX_SS_CONF="/data/nginx_self_signed_shib.conf"
  export NGINX_CA_CONF="/data/nginx_ca_shib.conf"
else
  export NGINX_SS_CONF="/data/nginx_self_signed.conf"
  export NGINX_CA_CONF="/data/nginx_ca.conf"
fi

# Create self-signed certificates
/data/self_signed.sh

# Start NGinx in daemon mode
echo "starting NGinx in daemon mode"
/usr/sbin/nginx

if [ "$USE_LETS_ENCRYPT" = true ]; then
  # Create CA certificates
  /data/create_cert.sh
fi

# Setup shibboleth
if [ "$USE_SHIBBOLETH" = true ] ; then
  /data/setup_shibboleth.sh
  # Stop NGinx. Let supervisor manage NGinx
  /usr/sbin/nginx -s stop
  /usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf
fi
