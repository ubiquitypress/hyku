# Generated via
#  `rails generate hyrax:work JournalArticle`

module Hyrax
  class JournalArticlesController < SharedBehaviorsController
    self.curation_concern_type = ::JournalArticle

    # Use this line if you want to use a custom presenter
    # self.show_presenter = Hyrax::JournalArticlePresenter
    #
    # Instead we include IIIFManifest which uses the manifest-enabled show
    # presenter
    include Hyku::IIIFManifest
  end
end
