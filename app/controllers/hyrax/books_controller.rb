# Generated via
#  `rails generate hyrax:work Book`

module Hyrax
  class BooksController < SharedBehaviorsController
    self.curation_concern_type = ::Book

    # Use this line if you want to use a custom presenter
    # self.show_presenter = Hyrax::BookPresenter
    #
    # Instead we include IIIFManifest which uses the manifest-enabled show
    # presenter
    include Hyku::IIIFManifest
  end
end
