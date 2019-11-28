# Generated via
#  `rails generate hyrax:work BookChapter`
class BookChapter < BookContribution
  self.indexer = BookChapterIndexer
  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  validates :title, presence: { message: 'Your work must have a title.' }

  self.human_readable_type = 'Book Chapter'

end
