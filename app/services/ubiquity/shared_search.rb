#call locally h = Ubiquity::SharedSearch.new(1, 'local')
#
module Ubiquity
  class SharedSearch

    Hash_keys = ["system_create_dtsi", "id", "depositor_ssim", "title_tesim", "creator_search_tesim",
                "creator_tesim", "account_cname_tesim",  "pagination_tesim", "institution_tesim",
                "resource_type_tesim", "thumbnail_path_ss", "file_set_ids_ssim",
                "visibility_ssi", "has_model_ssim", "date_published_tesim" ].freeze

    NAME_MAPPING = {
      "system_create_dtsi" => 'Date Created', "title_tesim" => 'Title',
      "creator_tesim" => 'Creator:', "resource_type_tesim" => 'Resource Type:',
      "date_published_tesim" => "Date Published:", "institution_tesim" => 'Institution:'
    }.freeze

    PER_PAGE_OPTIONS = [5, 10, 15, 25, 50, 100].freeze

    attr_accessor :tenant_names, :solr_url, :search_results,
                  :limit, :offset, :total_pages, :page

    def initialize(page, limit,  host)
      @page = page.to_i
      @limit = limit.to_i
      @records_size = []
      @search_results = []
      @accounts = Account.where("cname ILIKE ?", "%#{host}%")
      @tenant_names = @accounts.pluck(:cname)
      @solr_url  = @accounts.map {|j| j.solr_endpoint.options}.pluck('url')
      self
    end

    def current_page
      @page
    end

    def limit_value
      (@limit/@tenant_names.size).ceil
    end

   #cause of problems. when limit is 2 results in offset of -2 and @page is 1
    def offset
      @limit * ([@page, 1].max - 1)
    end

    def total_pages
      @total_pages = @records_size.inject(0, :+)
    end

    #page that is the page number eg 1, next will be 2
    #per_page is same as limit it can come from the page.
    #The offset on page 1 could be 0, while on page 2 will be 100 ie page time limit
    def all
       fetch_all
    end

    def fetch_term(search_term)
      if search_term.present?
        sanitized_value = sanitize_input(search_term)
        multiple_field_search(sanitized_value)
      end
    end

    private

    def fetch_all
      @solr_url.map do |url|
        solr_connection = RSolr.connect :url => url

        #fetch_total
        @get_data_for_total = solr_connection.get("select", params: { q: "*:*", fq: list_of_models_to_search })
        @records_size << @get_data_for_total["response"]["docs"].size

        @search_response = solr_connection.get("select", params: { q: '*:*', fq: list_of_models_to_search, start: offset, rows: @limit })
        data =  @search_response["response"]["docs"]
        search_results << data.map {|hash| hash.slice(*Hash_keys)}
      end
      search_results.flatten.compact
    end


    def multiple_field_search(search_term)
       @solr_url.map do |url|
         solr_connection = RSolr.connect :url => url

         #fetch_total
         @get_data_for_total = solr_connection.get("select", params: { q: "#{search_term}", fq: list_of_models_to_search } )
         @records_size << @get_data_for_total["response"]["docs"].size

         search_response = solr_connection.get "select", params: { q: "#{search_term}", fq: list_of_models_to_search }
         data = search_response["response"]["docs"]
         search_results << data.map {|hash| hash.slice(*Hash_keys)}
       end
       search_results.flatten.compact
    end

    def sanitize_input(search_value)
      regex = /[+ | ? * - ! ^ ~ ; :  || & ""]/
      search_value.gsub(regex, "")
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

  end
end
