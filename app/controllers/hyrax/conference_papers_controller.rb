# Generated via
#  `rails generate hyrax:work ConferencePaper`

module Hyrax
  class ConferencePapersController < SharedBehaviorsController
    self.curation_concern_type = ::ConferencePaper

    # Use this line if you want to use a custom presenter
    # self.show_presenter = Hyrax::ConferencePaperPresenter
    #
    # Instead we include IIIFManifest which uses the manifest-enabled show
    # presenter
    include Hyku::IIIFManifest
  end
end
