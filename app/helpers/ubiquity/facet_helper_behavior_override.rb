Blacklight::FacetsHelperBehavior.module_eval do

  def render_facet_partials fields = facet_field_names, options = {}
    if check_is_parent_shared_search_page.blank?
      fields.delete("institution_sim")
    end
    safe_join(facets_from_request(fields).map do |display_facet|
      render_facet_limit(display_facet, options)
    end.compact, "\n")
  end
end
