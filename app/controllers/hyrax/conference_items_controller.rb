module Hyrax
  class ConferenceItemsController < SharedBehaviorsController
    skip_load_and_authorize_resource only: [:manifest, :show]
    self.curation_concern_type = ::ConferenceItem

    # Use this line if you want to use a custom presenter
    # self.show_presenter = Hyrax::ConferenceItemPresenter
  
  end
end
