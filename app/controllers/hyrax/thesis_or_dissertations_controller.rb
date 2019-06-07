# Generated via
#  `rails generate hyrax:work ThesisOrDissertation`

module Hyrax
  class ThesisOrDissertationsController < SharedBehaviorsController
    skip_load_and_authorize_resource only: [:manifest, :show]
    self.curation_concern_type = ::ThesisOrDissertation

    # Use this line if you want to use a custom presenter
    #self.show_presenter = Hyrax::ThesisOrDissertationPresenter
  end
end
