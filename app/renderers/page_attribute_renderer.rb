# We create a custom renderer because the `pagination` attribute is otherwise passed and inherits from existing CSS class

class PageAttributeRenderer < Hyrax::Renderers::AttributeRenderer
  def render
    markup = ''
    values.delete("") if values # delete an empty string in array or it would display the field on works show page
    return markup if values.blank? && !options[:include_empty]
    markup << %(<tr><th>#{label}</th>\n
                <td><ul class='tabular'><li class='attribute page'>#{values.join}</li>
                </ul></td></tr>)
    markup.html_safe
  end
end