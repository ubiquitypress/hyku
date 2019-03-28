module Ubiquity
  module SharedSearchUtil
    extend ActiveSupport::Concern
    included do
      Hash_keys = ["system_create_dtsi", "id", "depositor_ssim", "title_tesim", "creator_search_tesim",
                  "creator_tesim",  "date_published_tesim", "resource_type_tesim", "account_cname_tesim",  "pagination_tesim", "institution_tesim",
                  "resource_type_tesim", "thumbnail_path_ss", "file_set_ids_ssim",
                  "visibility_ssi", "has_model_ssim" ].freeze

      NAME_MAPPING = {
        "system_create_dtsi" => 'Date Created', "title_tesim" => 'Title',
        "creator_tesim" => 'Creator:', "resource_type_tesim" => 'Resource Type:',
        "date_published_tesim" => "Date Published:", "institution_tesim" => 'Institution:'
      }.freeze

      PER_PAGE_OPTIONS = [10, 20, 50, 100].freeze

      SORT_OPTIONS =  [["relevance", "score desc, system_create_dtsi desc"], ["date uploaded ▼",
        "system_create_dtsi desc"], ["date uploaded ▲", "system_create_dtsi asc"]].freeze

      Facet_mappings = {
        'resource_type_sim'  => 'Resource Type',
        'institution_sim' => 'Institution',
        'creator_search_sim' => 'Creator',
        'keyword_sim' => 'Keyword',
        'member_of_collections_ssim' => 'Collections'
      }.freeze

    end
  end
end
