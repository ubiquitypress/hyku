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

    LIST_OF_MODELS_TO_SEARCH = "(has_model_ssim:Article OR has_model_ssim:Book OR has_model_ssim:BookContribution OR has_model_ssim:ConferenceItem OR has_model_ssim:Dataset OR has_model_ssim:Image OR has_model_ssim:Report OR has_model_ssim:GenericWork)".freeze

    PER_PAGE_OPTIONS = [5, 10, 15, 25, 50, 100].freeze

    attr_accessor :tenant_names, :solr_url, :search_results, :search_results_per_tenant,
                  :limit, :offset, :total_pages, :page

    def initialize(page, limit,  host)
      @page = page.to_i
      @limit = limit.to_i
      @records_size = []
      @search_results = []
      @search_results_per_tenant = {}
      @accounts = Account.where("cname ILIKE ?", "%#{host}%")
      @tenant_names = @accounts.pluck(:cname)
      @solr_url  = @accounts.map {|j| j.solr_endpoint.options}.pluck('url')
      build_hash
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
        multiple_field_search(search_term)
      end
    end

    private

    def fetch_all
      @solr_url.map do |url|
        solr_connection = RSolr.connect :url => url

        #fetch_total
        @get_data_for_total = solr_connection.get("select", params: { q: "*:*", fq: LIST_OF_MODELS_TO_SEARCH })
        @records_size << @get_data_for_total["response"]["docs"].size

        @search_response = solr_connection.get("select", params: { q: '*:*', fq: LIST_OF_MODELS_TO_SEARCH, start: offset, rows: limit })
        data =  @search_response["response"]["docs"]
        search_results << data.map {|hash| hash.slice(*Hash_keys)}
      end
      search_results.flatten.compact
    end


    def multiple_field_search(search_term)
       @solr_url.map do |url|
         solr_connection = RSolr.connect :url => url

         #fetch_total
         @get_data_for_total = solr_connection.get("select", params: { q: "#{search_term}", fq: LIST_OF_MODELS_TO_SEARCH } )
         @records_size << @get_data_for_total["response"]["docs"].size

         search_response = solr_connection.get "select", params: { q: "#{search_term}", fq: LIST_OF_MODELS_TO_SEARCH }
         data = search_response["response"]["docs"]
         search_results << data.map {|hash| hash.slice(*Hash_keys)}
       end
       search_results.flatten.compact
    end

    #a.tenant_names.each {|t| h[t] = []}
    def build_hash
      tenant_names.each do |tenant|
        search_results_per_tenant[tenant] = []
      end
    end

    def populate_new_hash(tenant_name, results_array)
      hash = build_hash
      #note id is an array
      hash[tenant_name] |= results_array
      hash
    end

    def fetch_hash(method_name, hash_value, tenant_name)
      array_method = self.send(method_name.to_sym)
      array_method.find {|hash| (hash[:work_class] == hash_value && hash[:tenant] == tenant_name)} if array_method.first.class == Hash
    end

  end
end
