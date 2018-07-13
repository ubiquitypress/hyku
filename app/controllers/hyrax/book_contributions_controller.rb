# Generated via
#  `rails generate hyrax:work BookContribution`

module Hyrax
  class BookContributionsController < SharedBehaviorsController
    self.curation_concern_type = ::BookContribution

    # Use this line if you want to use a custom presenter
    # self.show_presenter = Hyrax::BookContributionPresenter
    #
    # Instead we include IIIFManifest which uses the manifest-enabled show
    # presenter
    include Hyku::IIIFManifest
  end
end
