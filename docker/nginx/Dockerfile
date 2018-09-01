# Base image:
FROM anusha3/nginx-shibboleth-certbot:1.0

# establish where Nginx should look for files
ENV WEB_ROOT /var/www/web_server

# Set our working directory inside the image
WORKDIR $WEB_ROOT
RUN apt-get update && apt-get install -y procps

# create log directory
RUN rm -rf log
RUN mkdir log
RUN mkdir -p /etc/selfsigned /etc/letsencrypt /data/letsencrypt

# copy over static assets
COPY public public/

# Copy Nginx config files
COPY docker/nginx/nginx_self_signed.conf /data/nginx_self_signed.conf
COPY docker/nginx/nginx_self_signed_shib.conf /data/nginx_self_signed_shib.conf
COPY docker/nginx/nginx_ca.conf /data/nginx_ca.conf
COPY docker/nginx/nginx_ca_shib.conf /data/nginx_ca_shib.conf
COPY docker/nginx/shib_clear_headers /etc/nginx/shib_clear_headers
COPY docker/nginx/shib_fastcgi_params /etc/nginx/shib_fastcgi_params
COPY docker/nginx/nginx_conf_files /etc/nginx/include.d/
COPY docker/nginx/nginx_conf_files/ssl-ca /data/ssl-ca

# Copy scripts
COPY docker/web_server_env.sh /data/web_server_env.sh
COPY docker/nginx/start.sh /data/start.sh
COPY docker/nginx/self_signed.sh /data/self_signed.sh
COPY docker/nginx/create_cert.sh /data/create_cert.sh
COPY docker/shibboleth/setup_shibboleth.sh /data/setup_shibboleth.sh
RUN chmod +x /data/*.sh

# Copy Shibboleth2.xml
COPY ./docker/shibboleth/shibboleth2.xml /data/shibboleth2.xml

# COPY Cron data
COPY ./docker/nginx/cron_data /data/cron_data

EXPOSE 80 443

# Start NGinx, manage certificates, start supervisor for NGinx and Shibboleth
CMD [ "sh", "-c", "/data/start.sh && tail -F /dev/null;"]
