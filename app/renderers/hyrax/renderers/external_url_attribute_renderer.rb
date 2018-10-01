class ExternalUrlAttributeRenderer < Hyrax::Renderers::AttributeRenderer
  def render
    markup = ''
    values.delete("") if values # delete an empty string in array or it would display
    return markup if values.blank? && !options[:include_empty]
    link = values.is_a?(Array) ? values.join : values
    li_value(link)
  end

  private

  def li_value(value)
    markup = %(<tr><th>#{label}</th>\n<td><ul class='tabular'>)
    attributes = microdata_object_attributes(field).merge(class: "attribute attribute-#{field}")
    markup << "<li#{html_attributes(attributes)}>"
    markup << auto_link(value, html: { target: '_blank' })
    markup << %(</li></ul></td></tr>)
    markup.html_safe
  end
end
