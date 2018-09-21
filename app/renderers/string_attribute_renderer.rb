class StringAttributeRenderer < Hyrax::Renderers::AttributeRenderer

  def render
    markup = ''
    values.delete("") if values # delete an empty string in array or it would display the field on works show page
    return markup if values.blank? && !options[:include_empty]
    markup << %(<tr><th>#{label}</th>\n<td><ul class='tabular'>)
    attributes = microdata_object_attributes(field).merge(class: "attribute attribute-#{field}")
    Array(values).each do |value|
      markup << "<li#{html_attributes(attributes)}>#{attribute_value_to_html(value.to_s)}</li>"
    end
    markup << %(</ul></td></tr>)
    markup.html_safe
    super
  end
end