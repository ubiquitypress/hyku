# Generated via
#  `rails generate hyrax:work JournalArticle`
module Hyrax
  class JournalArticleForm < Hyrax::Forms::WorkForm
    include Hyrax::FormTerms
    include ::Ubiquity::AllFormsSharedBehaviour
    self.model_class = ::JournalArticle

    self.terms += %i[resource_type rendering_ids journal_title alternate_identifier doi volume issue pagination
                     place_of_publication issn eissn article_num date_published date_accepted date_submitted abstract
                     institution org_unit refereed official_link project_name funder fndr_project_ref add_info
                     rights_holder]
    self.terms -= %i[based_near description]
    self.required_fields += %i[resource_type journal_title institution publisher date_published]
    self.required_fields -= %i[keyword rights_statement]
  end
end
