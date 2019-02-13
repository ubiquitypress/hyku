FROM upress/hyku-base:experimental

ADD . /data

RUN bundle exec rake assets:precompile

EXPOSE 3000

ENTRYPOINT ["./docker-entrypoint.sh"]
