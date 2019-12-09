# Generated via
#  `rails generate hyrax:work ArticleWork`

module Hyrax
  class ArticleWorksController < SharedBehaviorsController
    skip_load_and_authorize_resource only: [:manifest, :show]
    self.curation_concern_type = ::ArticleWork

    # Use this line if you want to use a custom presenter
    #self.show_presenter = Hyrax::ArticleWorkPresenter
  end
end
