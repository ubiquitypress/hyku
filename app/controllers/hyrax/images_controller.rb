module Hyrax
  class ImagesController < SharedBehaviorsController
      skip_load_and_authorize_resource only: [:manifest, :show]
    self.curation_concern_type = ::Image

    # Use this line if you want to use a custom presenter
    # self.show_presenter = Hyrax::ImagePresenter

  end
end
