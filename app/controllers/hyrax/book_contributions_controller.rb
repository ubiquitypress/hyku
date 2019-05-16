# Generated via
#  `rails generate hyrax:work BookContribution`

module Hyrax
  class BookContributionsController < SharedBehaviorsController
    skip_load_and_authorize_resource only: [:manifest, :show]
    self.curation_concern_type = ::BookContribution

    # Use this line if you want to use a custom presenter
    # self.show_presenter = Hyrax::BookContributionPresenter
    #
  end
end
