# Generated via
#  `rails generate hyrax:work ThesisOrDissertationWork`

module Hyrax
  class ThesisOrDissertationWorksController < SharedBehaviorsController
    skip_load_and_authorize_resource only: [:manifest, :show]
    self.curation_concern_type = ::ThesisOrDissertationWork

    # Use this line if you want to use a custom presenter
    # self.show_presenter = Hyrax::ThesisOrDissertationWorkPresenter
  end
end
