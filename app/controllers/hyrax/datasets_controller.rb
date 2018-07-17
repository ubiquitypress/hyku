# Generated via
#  `rails generate hyrax:work Dataset`

module Hyrax
  class DatasetsController < SharedBehaviorsController
    self.curation_concern_type = ::Dataset

    # Use this line if you want to use a custom presenter
    # self.show_presenter = Hyrax::DatasetPresenter
    #
    # Instead we include IIIFManifest which uses the manifest-enabled show
    # presenter
    include Hyku::IIIFManifest
  end
end
