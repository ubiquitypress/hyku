FROM upress/hyku-base:latest

ADD . /data

RUN bundle exec rake assets:precompile

EXPOSE 3000
