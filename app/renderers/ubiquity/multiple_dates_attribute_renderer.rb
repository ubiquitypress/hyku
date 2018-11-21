class MultipleDatesAttributeRenderer < Hyrax::Renderers::AttributeRenderer

  def render
    markup = ''

    return markup if values.blank? && !options[:include_empty]
    markup << %(<tr><th>#{label}</th>\n<td><ul class='tabular'>)
    attributes = microdata_object_attributes(field).merge(class: "attribute attribute-#{field}")
    sorted_arr = Array(values).sort_by(&:downcase)
    sorted_arr.each do |value|
      # hide default values added to obtain a valid Date format; see 'all_models_virtual_fields'
      if value[(5..9)] == '01-01'
        value = value[(0..3)]
      elsif value[(8..9)] == '01'
        value = value[(0..6)]
      end
      markup << "<li#{html_attributes(attributes)}>#{attribute_value_to_html(value.to_s)}</li>"
    end
    markup << %(</ul></td></tr>)
    markup.html_safe
  end
end