# ApplicationController
module Ubiquity
  class SharedSearchController < ProprietorController
    before_action :set_page, only: [:index]
    before_action :set_per_page, only: [:index]

    def index
      # Parameters: {"utf8"=>"✓", "term"=>"", "commit"=>"search"}
      @search_results = return_search #.search_results
      @search_pagination = Kaminari.paginate_array(@search_results, total_count: @search.total_pages).page(@page).per(@per_page.to_i)
    end

    private

    def return_search
      @search = Ubiquity::SharedSearch.new(@page, @per_page, request.host)
      if params["term"].present?
        add_seach_term_session(params["term"])
        @search.fetch_term(params["term"])
      else
        remove_seach_term_session
        @search.all
      end
    end

    def set_page
      @page = params[:page]|| 1
    end

    def set_per_page
      #we are storing params[:limit] in cookies[:per_page] because the dropdown
      #will have no default value passed in, so we can
      cookies[:per_page] = params[:limit] || 10
      @per_page =  cookies[:per_page]
    end

    def add_seach_term_session(term)
      session[:previous_search_term] = term
    end

    def remove_seach_term_session
      session.delete(:previous_search_term)
      #
    end

  end
end
