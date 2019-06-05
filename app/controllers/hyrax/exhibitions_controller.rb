# Generated via
#  `rails generate hyrax:work Exhibition`

module Hyrax
  class ExhibitionsController < SharedBehaviorsController
    skip_load_and_authorize_resource only: [:manifest, :show]
    self.curation_concern_type = ::Exhibition

    # Use this line if you want to use a custom presenter
    #self.show_presenter = Hyrax::ExhibitionPresenter
  end
end
