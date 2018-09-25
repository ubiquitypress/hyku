#!/bin/bash

# Configure files requirement when creating a work
if ! grep -F "config.work_requires_files = false" config/initializers/hyrax.rb
then
  sed -i -e "105a\ config.work_requires_files = $WORK_REQUIRES_FILES" config/initializers/hyrax.rb
fi

bundle exec rails server -p 3000 -b '0.0.0.0'
