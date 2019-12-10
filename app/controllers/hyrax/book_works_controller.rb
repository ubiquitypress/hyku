# Generated via
#  `rails generate hyrax:work BookWork`

module Hyrax
  class BookWorksController < SharedBehaviorsController
    skip_load_and_authorize_resource only: [:manifest, :show]
    self.curation_concern_type = ::BookWork

    # Use this line if you want to use a custom presenter
    #self.show_presenter = Hyrax::BookWorkPresenter
  end
end
