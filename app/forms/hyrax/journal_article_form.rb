# Generated via
#  `rails generate hyrax:work JournalArticle`
module Hyrax
  class JournalArticleForm < Hyrax::Forms::WorkForm
    include Hyrax::FormTerms
    self.model_class = ::JournalArticle
    self.terms += [:resource_type]
  end
end
