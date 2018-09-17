module Hyrax
  class ArticleForm < Hyrax::Forms::WorkForm
    include Hyrax::FormTerms
    include ::Ubiquity::AllFormsSharedBehaviour
    self.model_class = ::Article

    self.terms += %i[title resource_type creator contributor rendering_ids doi journal_title
                     alternate_identifier related_identifier volume issue pagination publisher
                     place_of_publication issn eissn article_num date_published date_accepted date_submitted
                     abstract keyword institution org_unit refereed official_link related_url project_name
                     funder fndr_project_ref add_info language license rights_statement rights_holder]
    self.required_fields += %i[journal_title]
  end
end
