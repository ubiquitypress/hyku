#!/bin/bash

# Configure files requirement when creating a work
if ! grep -F "config.work_requires_files = false" config/initializers/hyrax.rb
then
  sed -i -e "105a\ config.work_requires_files = $WORK_REQUIRES_FILES" config/initializers/hyrax.rb
fi

# zookeeper
bundle exec rails zookeeper:upload

# Start sidekiq
bundle exec sidekiq -d -q ubiquity_json_importer,2 -q default,2 -q expiry_service,1 -L kiq.log

# Start server
rm -f tmp/pids/server.pid && bundle exec rails db:migrate && bundle exec rails server -p 3000 -b '0.0.0.0'
