# ApplicationController
module Ubiquity
  class SharedSearchController < ProprietorController
    before_action :set_page, only: [:index]
    before_action :set_per_page_cookie, only: [:index]
    before_action :set_sort_cookie, only: [:index]

    def index
      @search_results = return_search
      @search_pagination = Kaminari.paginate_array(@search_results, total_count: @search.total_pages).page(@page).per(@per_page.to_i)
    end

    private

    def return_search
      @search = Ubiquity::SharedSearch.new(@page, @per_page, request.host, @sort_value)

      if params["q"].present?
        add_search_term_cookie(params["q"])
        @search.fetch_term(params["q"])
      else
        remove_search_term_cookie
        @search.all
      end
    end

    def set_page
      @page = params[:page]|| 1
    end

    #we are storing params[:limit] in cookies[:per_page] because
    #the dropdown will have no default value passed in,
    #so we can use the cookie inplace explicit setting default value
    #
    def set_per_page_cookie
      cookies[:per_page] = params[:per_page] || 10
      @per_page =  cookies[:per_page]
    end

    def set_sort_cookie #(sort_value)
      cookies[:sort] = params[:sort] || "score desc, system_create_dtsi desc"
      @sort_value = cookies[:sort]
    end

    def add_search_term_cookie(term)
      cookies[:search_term] = term
    end

    #remove if facet is empty
    def remove_search_term_cookie
      cookies.delete(:search_term)
    end

  end
end
