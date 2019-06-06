# Generated via
#  `rails generate hyrax:work TimeBasedMedia`

module Hyrax
  class TimeBasedMediasController < SharedBehaviorsController
    skip_load_and_authorize_resource only: [:manifest, :show]
    self.curation_concern_type = ::TimeBasedMedia


  end
end
