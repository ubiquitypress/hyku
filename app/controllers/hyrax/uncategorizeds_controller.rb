# Generated via
#  `rails generate hyrax:work Uncategorized`

module Hyrax
  class UncategorizedsController < SharedBehaviorsController
    skip_load_and_authorize_resource only: [:manifest, :show]
    self.curation_concern_type = ::Uncategorized

    # Use this line if you want to use a custom presenter
    #self.show_presenter = Hyrax::UncategorizedPresenter
  end
end
