# Generated via
#  `rails generate hyrax:work BookChapter`

module Hyrax
  class BookChaptersController < SharedBehaviorsController
    skip_load_and_authorize_resource only: [:manifest, :show]
    self.curation_concern_type = ::BookChapter

    # Use this line if you want to use a custom presenter
    #self.show_presenter = Hyrax::BookChapterPresenter
  end
end
