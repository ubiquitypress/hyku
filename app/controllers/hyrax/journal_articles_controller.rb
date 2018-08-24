# Generated via
#  `rails generate hyrax:work JournalArticle`

module Hyrax

  class JournalArticlesController < SharedBehaviorsController
  #class JournalArticlesController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks

    include Ubiquity::GlobalSharedMetadataControllersBehaviour

    include Hyku::IIIFManifest
    #self.curation_concern_type = ::JournalArticle
    self.curation_concern_type = JournalArticle

    # Use this line if you want to use a custom presenter
    #self.show_presenter = Hyku::JournalArticlePresenter

  end
end
