# Generated via
#  `rails generate hyrax:work ImageWork`

module Hyrax
  class ImageWorksController < SharedBehaviorsController
    skip_load_and_authorize_resource only: [:manifest, :show]
    self.curation_concern_type = ::ImageWork

    # Use this line if you want to use a custom presenter
    #self.show_presenter = Hyrax::ImageWorkPresenter
  end
end
