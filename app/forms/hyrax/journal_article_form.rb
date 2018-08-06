# Generated via
#  `rails generate hyrax:work JournalArticle`
module Hyrax
  class JournalArticleForm < Hyrax::Forms::WorkForm
    include Hyrax::FormTerms
    self.model_class = ::JournalArticle
    self.terms += %i[resource_type rendering_ids institution org_unit refereed funder fndr_project_ref
                     add_info date_published date_accepted date_submitted]
    self.required_fields += [:date_published]
  end
end
