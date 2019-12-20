# Generated via
#  `rails generate hyrax:work Presentation`

module Hyrax
  class PresentationsController < SharedBehaviorsController
    skip_load_and_authorize_resource only: [:manifest, :show]
    self.curation_concern_type = ::Presentation

    # Use this line if you want to use a custom presenter
    #self.show_presenter = Hyrax::PresentationPresenter
  end
end
