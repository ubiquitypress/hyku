#call locally h = Ubiquity::SharedSearch.new(1, 10, 'local')
#
module Ubiquity
  class SharedSearch

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

    attr_accessor :tenant_names, :solr_url, :search_results,
                  :limit, :offset, :total_pages, :page, :demo_records,
                  :live_records, :live_tenant_names, :demo_tenant_names,
                  :live_solr_urls, :demo_solr_urls

    def initialize(page, limit,  host)
      @page = page.to_i
      @limit = limit.to_i

      @records_size = []
      @search_results = []
      @accounts = Account.where("cname ILIKE ?", "%#{host}%")

      @demo_records = @accounts.map {|acct| j if acct.cname.include? 'demo'}.compact
      @live_records = @accounts - @demo_records

      @live_tenant_names = @live_records.pluck(:cname)

      @live_solr_urls = @live_records.map {|j| j.solr_endpoint.options}.pluck('url')

      #self
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
      @live_solr_urls.map do |url|
        solr_connection = RSolr.connect :url => url
        search_response = solr_connection.get("select", params: { q: "*:* or visibility_ssi:open", fq: list_of_models_to_search, sort: "score desc, system_create_dtsi desc"})
        @records_size << search_response["response"]["docs"].size
        data =  search_response["response"]["docs"]
        search_results << data.map {|hash| hash.slice(*Hash_keys)}
      end
      search_results.flatten.compact
    end


    def multiple_field_search(search_term)
       fl = 'title_ssim, resource_type_tesim, institution_tesim, date_published_tesim, account_cname_tesim, thumbnail_path_ss, id, visibility_ssi, creator_tesim, creator_search_tesim, has_model_ssim'
       #fields to search against
       qf = "title_tesim description_tesim keyword_tesim creator_tesim creator_search_ssim date_published_tesim  date_created_tesim resource_type_ssim institution_tesim "

       @live_solr_urls.map do |url|
         solr_connection = RSolr.connect :url => url
         #fetch_total
         search_response = solr_connection.get("select", params: { q: "#{search_term} or visibility_ssi:open", :defType => "edismax", fq: list_of_models_to_search, qf: qf, sort: "score desc, system_create_dtsi desc" } )
         @records_size << search_response["response"]["docs"].size
         #data = @get_data_for_total["response"]["docs"]
         #@records_size <<  @search_response["response"]["docs"].size
         data =  search_response["response"]["docs"]
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

  end
end
