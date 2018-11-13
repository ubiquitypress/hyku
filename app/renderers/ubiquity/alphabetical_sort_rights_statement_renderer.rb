class AlphabeticalSortRightsStatementRenderer < Hyrax::Renderers::RightsStatementAttributeRenderer

  def render
    markup = ''

    return markup if values.blank? && !options[:include_empty]
    markup << %(<tr><th>#{label}</th>\n<td><ul class='tabular'>)
    attributes = microdata_object_attributes(field).merge(class: "attribute attribute-#{field}")
    sort_by_term.each do |value|
      markup << "<li#{html_attributes(attributes)}>#{attribute_value_to_html(value.to_s)}</li>"
    end
    markup << %(</ul></td></tr>)
    markup.html_safe
  end

  # `values` are ids from the controlled vocabulary. e.g.'http://rightsstatements.org/vocab/InC/1.0/'
  # see config/authorities/rights_statements.yml
  # Order alphabetically by term displayed (e.g. 'In Copyright') instead of id
  def sort_by_term
    qa_terms_arr = []
    values.each do |qa_id|
      qa_terms_arr << Hyrax.config.rights_statement_service_class.new.label(qa_id)
    end
    sorted_terms = qa_terms_arr.sort_by(&:downcase)
    sorted_licenses = []
    sorted_terms.each do |t|
      values.each do |v|
        sorted_licenses << v if Hyrax.config.rights_statement_service_class.new.label(v) == t
      end
    end
    sorted_licenses
  end

  private

    def attribute_value_to_html(value)
      super
    end
end
