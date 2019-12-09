# Generated via
#  `rails generate hyrax:work NewsClipping`

module Hyrax
  class NewsClippingsController < SharedBehaviorsController
    skip_load_and_authorize_resource only: [:manifest, :show]
    self.curation_concern_type = ::NewsClipping

    # Use this line if you want to use a custom presenter
    #self.show_presenter = Hyrax::NewsClippingPresenter
  end
end
