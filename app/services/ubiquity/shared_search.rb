#call locally h = Ubiquity::SharedSearch.new(1, 10, 'local')

#encoding: UTF-8
#https://markhneedham.com/blog/2013/01/27/ruby-invalid-multibyte-char-us-ascii/

module Ubiquity
  class SharedSearch
    #include Ubiquity::SharedSearchUtils
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

    attr_accessor :tenant_names, :solr_url, :search_results,
                  :limit, :offset, :total_pages, :page, :demo_records,
                  :live_records, :live_tenant_names, :demo_tenant_names,
                  :live_solr_urls, :demo_solr_urls, :sort, :facet_values,
                  :facet_filtering

    def initialize(page, limit, host, sort=nil)
      @facet_values = {}
      @page = page.to_i
      @limit = limit.to_i
      @sort = sort

      @records_size = []
      @search_results = []
      @accounts = Account.where("cname ILIKE ?", "%#{host}%")

      @demo_records = @accounts.map {|acct| j if acct.cname.include? 'demo'}.compact
      @live_records = @accounts - @demo_records

      @live_tenant_names = @live_records.pluck(:cname)
      @live_solr_urls = @live_records.map {|acct| acct.solr_endpoint.options}.pluck('url')
    end

    def current_page
      @page
    end

    def limit_value
      (@limit/live_tenant_names.size).ceil
    end

   #cause of problems. when limit is 2 results in offset of -2 and @page is 1
    def offset
      limit_value * ([@page, 1].max - 1)
    end

    def total_pages
      @total_pages = @records_size.inject(0, :+)
    end

    def all
       fetch_all
    end

    def fetch_term(search_term)
      if search_term.present?
        sanitized_value = clean_and_downcase_user_search_term(search_term)
        multiple_field_search(sanitized_value)
      end
    end

    def facet_filter_query(filters)
      if filters.present?
        term = build_query_params_from_facet_values(filters)
        multiple_field_search(term)
      end
    end

    def combined_filter_query(search_term, filters)
      facet_query_terms = build_query_params_from_facet_values(filters)
      search_input = clean_and_downcase_user_search_term(search_term)
      combined_terms = facet_query_terms.prepend("#{search_input} OR ")
      multiple_field_search(combined_terms)
    end

    # maby_by without calling .to_h return_search
      #{:institution_sim=>[["Tate", 1], ["British Museum", 1], ["MOLA", 1], ["British Library", 1]]}
    # max_by with .to_h returns {:institution_sim=>{"Tate"=>1, "British Museum"=>1, "MOLA"=>1, "British Library"=>1}}
    #
    def five_values_from_facet_hash
     selected_facet = {}
     number = ENV['BL_SHARED_SEARCH_FACETS_SIZE']
     facet_size = number.present? ? number : 5
     facet_values.each { |key, value| selected_facet[key] = value.max_by(facet_size.to_i, &:last).to_h }
     selected_facet
    end

    def valid_json?(data)
      !!JSON.parse(data)  if data.class == String
      rescue JSON::ParserError
        false
    end

    private

    def fetch_all
      @live_solr_urls.map do |url|
        solr_connection = RSolr.connect :url => url
        search_response = solr_connection.get("select", params: { q: "*:* or visibility_ssi:open", fq: list_of_models_to_search, sort: sort, rows: 1000, "facet.field" => facet_fields })
        @records_size << search_response["response"]["docs"].size
        facet_data = search_response["facet_counts"]['facet_fields']
        remap_facet_values(facet_data)
        data =  search_response["response"]["docs"]
        search_results << data.map {|hash| hash.slice(*Hash_keys)}
      end
      search_results.flatten.compact
    end

    def multiple_field_search(search_term)
      #fields to return
       fl = 'title_ssim, resource_type_tesim, institution_tesim, date_published_tesim, account_cname_tesim, thumbnail_path_ss, id, visibility_ssi, creator_tesim, creator_search_tesim, has_model_ssim'
       #fields to search against
       #
       qf = "title_tesim description_tesim keyword_tesim journal_title_tesim subject_tesim creator_tesim version_tesim related_exhibition_tesim media_tesim event_title_tesim event_date_tesim
        event_location_tesim abstract_tesim book_title_tesim series_name_tesim edition_tesim contributor_tesim publisher_tesim place_of_publication_tesim date_published_tesim based_near_label_tesim
        language_tesim date_uploaded_tesim date_modified_tesim date_created_tesim rights_statement_tesim license_tesim resource_type_tesim format_tesim identifier_tesim doi_tesim isbn_tesim
        issn_tesim eissn_tesim extent_tesim institution_tesim org_unit_tesim refereed_tesim funder_tesim fndr_project_ref_tesim add_info_tesim date_accepted_tesim issue_tesim volume_tesim
         pagination_tesim article_num_tesim project_name_tesim official_link_tesim rights_holder_tesim library_of_congress_classification_tesim file_format_tesim all_text_timv"

       @live_solr_urls.map do |url|
         solr_connection = RSolr.connect :url => url
         search_response = solr_connection.get("select", params: { q: "#{search_term} or visibility_ssi:open", :defType => "edismax", fq: list_of_models_to_search, qf: qf, sort: sort, rows: 1000, "facet.field" => facet_fields } )
        #add to total
         @records_size << search_response["response"]["docs"].size
         facet_data = search_response["facet_counts"]['facet_fields']
         remap_facet_values(facet_data)
         #pull out the data from the response
         data =  search_response["response"]["docs"]
         #return only the desired hash keys
         search_results << data.map {|hash| hash.slice(*Hash_keys)}
       end
       search_results.flatten.compact
    end

    def sanitize_input(search_value)
      regex = /[+ | ? * - ! ^ ~ ; :  || & ""]/
      search_value.gsub(regex, " ")
    end

    def list_of_models_to_search
      model_names_array = ENV["SHARED_SEARCH_TYPES"].split(',')
      model_names_string = "("
      model_names_array.each_with_index do |model_name, index|
        model_names_string << "has_model_ssim:#{model_name}" if  index == 0
        model_names_string << " OR has_model_ssim:#{model_name}" if index <   model_names_array.size
        model_names_string << " OR has_model_ssim:#{model_name})" if index == (model_names_array.size - 1)
      end
      model_names_string
    end

    #turns the result of query from multi-dimensional array to nested hash
    #eg {institution_sim: [[tate, 1] [mola, 1]]}
    #into {institution_sim: {tate: 1, mola: 1}}
    #
    def remap_facet_values(facet_data)
      new_facet_hash = { }
      facet_data.each { |key, value| new_facet_hash[key] = Hash[*facet_data[key].flatten(1)]}
      @facet_values.deep_merge!(new_facet_hash) { |key, this_val, other_val| this_val + other_val }
      new_facet_hash.clear
      facet_values
    end

    #facet fields to return in query response 'keyword_sim', "member_of_collections_ssim"
    def facet_fields
      facet_to_display = ENV['BL_SHARED_SEARCH_FACETS']
      if facet_to_display.present?
        facet_to_display.split(',')
      else
        ['resource_type_sim', 'creator_search_sim', 'institution_sim']
      end
    end

    def clean_and_downcase_user_search_term(search_term)
      sanitized_term = sanitize_input(search_term)
      sanitized_term #.downcase
    end

    def build_query_params_from_facet_values(filters)
      data = filters
      #needed because when deleting multiple filters, a string is sometimes sent instead of hash
      #if the rquest is from the destroy action or a form submission
      data = JSON.parse(filters) if valid_json?(filters)
      term = ""
      data.each_with_index do |(key, value), index|
        #term << "#{key}:#{value}"  if index == 0
        #term << " OR #{key}:#{value}"  if index > 0
        term << "#{value}"  if index == 0
        term << " OR #{value}"  if index > 0
      end
      term
    end

  end
end
