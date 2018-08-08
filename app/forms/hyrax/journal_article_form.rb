# Generated via
#  `rails generate hyrax:work JournalArticle`
module Hyrax
  class JournalArticleForm < Hyrax::Forms::WorkForm
    include Hyrax::FormTerms
    self.model_class = ::JournalArticle
    self.terms += %i[resource_type rendering_ids journal_title doi volume issue pagination issn eissn
                     article_num date_published date_accepted date_submitted institution org_unit refereed
                     official_link project_name funder fndr_project_ref add_info rights_holder]
    self.required_fields += %i[journal_title institution publisher date_published]
    self.required_fields -= %i[keyword rights_statement]
  end
end
