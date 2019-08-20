class ExternalUrlAttributeRenderer < Hyrax::Renderers::AttributeRenderer

  def render
    markup = ''
    values.delete("") if values # delete an empty string in array or it would display
    return markup if values.blank? && !options[:include_empty]
    arr_of_li_values(values) if values.is_a?(Array)
  end

  private

    def arr_of_li_values(value)
      markup = %(<tr><th>#{label}</th>\n<td><ul class='tabular'>)
      attributes = microdata_object_attributes(field).merge(class: "attribute attribute-#{field}")
      markup << "<li#{html_attributes(attributes)}>"
      sorted_arr = value.sort_by(&:downcase)
      links = sorted_arr.map do |url|
        complete_url = "https://" + url
        if label == 'DOI'
          auto_link(complete_url, html: { target: '_blank' })
        else
          auto_link(url, html: { target: '_blank' })
        end
      end
      markup << links.join('<br/>')
      markup << %(</li></ul></td></tr>)
      markup.html_safe
    end

end
