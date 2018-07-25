module Hyrax
  class ConferenceItemsController < SharedBehaviorsController
    self.curation_concern_type = ::ConferenceItem

    # Use this line if you want to use a custom presenter
    # self.show_presenter = Hyrax::ConferenceItemPresenter
    #
    # Instead we include IIIFManifest which uses the manifest-enabled show
    # presenter
    include Hyku::IIIFManifest
  end
end
