# Generated via
#  `rails generate hyrax:work TextWork`

module Hyrax
  class TextWorksController < SharedBehaviorsController
    skip_load_and_authorize_resource only: [:manifest, :show]
    self.curation_concern_type = ::TextWork

    # Use this line if you want to use a custom presenter
    #self.show_presenter = Hyrax::TextWorkPresenter
  end
end
