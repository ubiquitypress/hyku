# ApplicationController
module Ubiquity
  class SharedSearchController < ProprietorController
    before_action :set_page, only: [:index, :facet]
    before_action :set_per_page_cookie, only: [:index, :facet]
    before_action :set_sort_cookie, only: [:index, :facet]
    before_action :set_facet_cookie, only: [:index, :facet]
    before_action :set_parmitted_params, only: [:index, :facet]

    def index
      @search_results = return_search
      @facet_records = @search.five_values_from_facet_hash  #@search.facet_values
      @search_pagination = Kaminari.paginate_array(@search_results, total_count: (@search.total_pages) ).page(@page).per(@per_page.to_i)
    end

    def facet
      @search_results = return_search
      @facet_records = @search.facet_values
      @facet_key = params['more_field']
      @facet_more = @facet_records[@facet_key]
      respond_to do |format|
        format.js
      end
    end

    def destroy
      if  params["f"].present?
        hash =   helpers.turn_params_facet_to_hash
        cookie_hash = remove_facet_cookie(hash.keys.first)
        redirect_to shared_search_index_url(per_page: cookies[:per_page], sort: cookies[:sort], f: cookies[:facet], q: cookies[:search_term])
      else
        remove_search_term_cookie
        redirect_to shared_search_index_url(per_page: cookies[:per_page], sort: cookies[:sort], f: cookies[:facet])
      end
    end

    private

    def set_parmitted_params
      params = ActionController::Parameters.new({q: '', sort: '', per_page: '', f: ''})
      params.permit(:q, :sort, :per_page, f:  [:institution_sim, :creator_search_sim, :resource_type_sim])
    end

    def return_search
      @search = Ubiquity::SharedSearch.new(@page, @per_page, request.host, @sort_value)

      if params["q"].blank? && params["f"].blank?
        remove_all_cookies
        @search.all
      elsif (params["q"].present?  &&  cookies[:facet].present?) || (params[:sort].present? && get_facet_hash.present?)  || (params[:per_page].present? && get_facet_hash.present?)
        add_search_term_cookie(params["q"])
        set_facet_cookie
        return @search.combined_filter_query(params["q"], helpers.facet_cookie_to_hash) if params[:q].present?
        return @search.facet_filter_query(helpers.facet_cookie_to_hash) if params[:q].blank?
      elsif  params["q"].present?
        add_search_term_cookie(params["q"])
        @search.fetch_term(params["q"])
      elsif params["f"].present?
        set_facet_cookie
        @search.facet_filter_query(helpers.facet_cookie_to_hash)
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

    def set_sort_cookie
      cookies[:sort] = params[:sort] || "score desc, system_create_dtsi desc"
      @sort_value = cookies[:sort]
    end

    def add_search_term_cookie(term)
      cookies[:search_term] = term
    end

    def set_facet_cookie
      if params[:f].present?
        hash = helpers.turn_params_facet_to_hash
        if cookies[:facet].blank?
          cookies[:facet] = JSON.generate(hash) if hash.present?
        else
           cookie_hash = helpers.facet_cookie_to_hash if helpers.facet_cookie_to_hash
           new_hash = cookie_hash.merge(hash) if hash.present?
           cookies[:facet] = JSON.generate(new_hash) if new_hash.present?
        end
      end
    end

    def remove_facet_cookie(cookie_key)
      cookie_hash = helpers.facet_cookie_to_hash
      if  cookie_hash.nil? || cookie_hash.size == 1
        cookies.delete(:facet)
      else
        cookie_hash.delete(cookie_key)
        cookie_hash
        cookies[:facet] = JSON.generate(cookie_hash)
      end
    end

    #remove if facet is empty
    def remove_search_term_cookie
      cookies.delete(:search_term)
    end

    def remove_all_cookies
      cookies.delete(:search_term)
      cookies.delete(:facet)
    end

    def get_facet_hash
      helpers.turn_params_facet_to_hash || helpers.facet_cookie_to_hash
    end

  end
end
