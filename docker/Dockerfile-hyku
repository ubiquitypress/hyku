FROM ruby:2.3.1
RUN apt-get update -qq && \
    apt-get install -y build-essential libpq-dev nodejs libreoffice imagemagick unzip ghostscript gettext-base && \
    rm -rf /var/lib/apt/lists/*
# If changes are made to fits version or location,
# amend `LD_LIBRARY_PATH` in docker-compose.yml accordingly.
RUN mkdir -p /opt/fits && \
    curl -fSL -o /opt/fits-1.0.5.zip http://projects.iq.harvard.edu/files/fits/files/fits-1.0.5.zip && \
    cd /opt && unzip fits-1.0.5.zip && chmod +X fits-1.0.5/fits.sh

RUN mkdir /data
WORKDIR /data
ADD Gemfile /data/Gemfile
ADD Gemfile.lock /data/Gemfile.lock
RUN bundle install
ADD . /data

# Replace domain in config/settings.yml
ARG DOMAIN=$DOMAIN
RUN envsubst '$DOMAIN' < /data/config/settings.yml > /data/config/settings2.yml
RUN mv /data/config/settings2.yml /data/config/settings.yml

RUN bundle exec rake assets:precompile
EXPOSE 3000
