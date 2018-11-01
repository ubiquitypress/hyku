FROM upress/hyku-base:latest

ADD . /data

RUN gem install bundler

RUN bundle install

RUN bundle exec rake assets:precompile

EXPOSE 3000

ENTRYPOINT ["./docker-entrypoint.sh"]
