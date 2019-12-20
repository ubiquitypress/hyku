# Generated via
#  `rails generate hyrax:work Media`

module Hyrax
  class MediasController < SharedBehaviorsController
    skip_load_and_authorize_resource only: [:manifest, :show]
    self.curation_concern_type = ::Media

    # Use this line if you want to use a custom presenter
    #self.show_presenter = Hyrax::MediaPresenter
  end
end
