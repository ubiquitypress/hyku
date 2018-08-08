# Generated via
#  `rails generate hyrax:work JournalArticle`
module Hyrax
  class JournalArticleForm < Hyrax::Forms::WorkForm
    include Hyrax::FormTerms
    self.model_class = ::JournalArticle
    self.terms += %i[resource_type rendering_ids institution org_unit refereed official_link funder fndr_project_ref
                     add_info date_published date_accepted date_submitted journal_title issue volume
                     pagination article_num project_name rights_holder doi issn eissn]
    self.required_fields += %i[journal_title date_published]
  end
end
