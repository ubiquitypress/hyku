FROM ruby:2.3.1

RUN apt-get update -qq && \
    apt-get install -y \
        build-essential \
        libpq-dev \
        nodejs \
        libreoffice \
        imagemagick \
        unzip \
        ghostscript \
        && \
    rm -rf /var/lib/apt/lists/*
# If changes are made to fits version or location,
# amend `LD_LIBRARY_PATH` in docker-compose.yml accordingly.
RUN mkdir -p /opt/fits && \
    curl -fSL -o /opt/fits-1.0.5.zip http://projects.iq.harvard.edu/files/fits/files/fits-1.0.5.zip && \
    cd /opt && unzip fits-1.0.5.zip && \
    chmod +X fits-1.0.5/fits.sh

RUN mkdir /data
WORKDIR /data

# Install Python libs required to run the metadata importer with Nameko
ADD requirements.txt /data
RUN apt-get update -qq && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y python-pip python-dev && \
    pip install --no-input -r requirements.txt

# Install ffmpeg required to get videos to work.
RUN echo 'deb http://ftp.uk.debian.org/debian jessie-backports main' >> /etc/apt/sources.list
RUN apt-get update && \
    apt-get install -y ffmpeg

ADD Gemfile /data/Gemfile
ADD Gemfile.lock /data/Gemfile.lock

RUN bundle install

ADD . /data

RUN bundle exec rake assets:precompile

EXPOSE 3000

ENTRYPOINT ["./docker-entrypoint.sh"]