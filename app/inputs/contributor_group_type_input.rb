#
#Credits  Chris Colvard of Avalon Media System
# fir guidance and code samples
# ---  END LICENSE_HEADER BLOCK  ---

=begin
class ContributorGroupTypeInput < MultiValueInput

  # Override to include contributor_group_type class
  def inner_wrapper
    <<-HTML
      <li class="field-wrapper contributor_group_type">
        #{yield}
      </li>
    HTML
  end

  def common_field_options
    options = {}
    options[:class] ||= []
    options[:class] += ["#{input_dom_id} form-control multi-text-field multi_value"]
    options[:'aria-labelledby'] = label_id
    options
  end

  def select_input_html_options
    common_field_options.dup.merge(
        #name: "#{@builder.object_name}[contributor_group][][contributor_list]",
        name: "#{@builder.object_name}[contributor_list][]",
        #id: "#{@builder.object_name}_contributor_group_contributor_list",
        id: nil,
        required: nil
    )
  end

  def text_area_input_html_options(value)
    puts "text area value is #{value}"
    common_field_options.dup.merge(
        #name: "#{@builder.object_name}[contributor_group][][contributor_name]",
        name: "#{@builder.object_name}[contributor_name][]",
        id: nil,
        required: nil,
        placeholder: 'Add contributor name',
        value: value
    )
  end

  def text_input_html_options(value)
    puts "text input value is #{value}"
    common_field_options.merge(
        #name: "#{@builder.object_name}[contributor_group][][contributor_id]",
        name: "#{@builder.object_name}[contributor_id][]",
        id: nil,
        required: nil,
        placeholder: 'Add contributor orcid',
        value: value
    )
  end

  def build_field(value, _index)

    @rendered_first_element = true
    contributor_list_choices = ContributorGroupService.new.select_active_options
    output = @builder.select(:contributor_list, contributor_list_choices, { selected: value[0] }, select_input_html_options)
    output += @builder.text_area(:contributor_name, text_area_input_html_options(value[1]))
    output += @builder.text_field(:contributor_id, text_input_html_options(value[2]))
    output

  end

end

=end

class ContributorGroupTypeInput < MultiValueSelectInput
  # Override to include contributor_group_type class
  def inner_wrapper
    <<-HTML
      <li class="field-wrapper contributor_group_type">
        #{yield}
      </li>
    HTML
  end

  def common_field_options
    options = {}
    options[:class] ||= []
    options[:class] += ["#{input_dom_id} form-control multi-text-field multi_value"]
    options[:'aria-labelledby'] = label_id
    options
  end

  def select_input_html_options
    common_field_options.dup.merge(
        #name: "#{@builder.object_name}[contributor_group][][contributor_list]",
        name: "#{@builder.object_name}[contributor_list][]",
        #id: "#{@builder.object_name}_contributor_group_contributor_list",
        id: nil,
        required: nil
    )
  end

  def text_area_input_html_options(value)
    puts "text area value is #{value}"
    common_field_options.dup.merge(
        #name: "#{@builder.object_name}[contributor_group][][contributor_name]",
        name: "#{@builder.object_name}[contributor_name][]",
        id: nil,
        required: nil,
        placeholder: 'Add contributor name',
        value: value
    )
  end

  def text_input_html_options(value)
    puts "text input value is #{value}"
    @rendered_first_element = true
    common_field_options.merge(
        #name: "#{@builder.object_name}[contributor_group][][contributor_orcid]",
        name: "#{@builder.object_name}[contributor_id][]",
        id: nil,
        required: nil,
        #placeholder: 'Add contributor id',
        value: value
    )
  end

  def build_field(value, _index)

    @rendered_first_element = true
    contributor_list_choices = ContributorGroupService.new.select_active_options
    output = @builder.select(:contributor_list, contributor_list_choices, { selected: value[0] }, select_input_html_options)
    output += @builder.text_area(:contributor_name, text_area_input_html_options(value[1]))
    output += @builder.text_field(:contributor_id, text_input_html_options(value[2]))
    output

  end

end

=begin

class ContributorGroupTypeInput < MultiValueInput

  def build_field(value, index)
    #TODO this data needs to come from a controlled vocab of title types
    # rather than being hardcoded here.
    #title_type_choices = TitleAndDescriptionTypesService.select_all_options
    #select_input_html_options = { name: "#{@builder.object_name}[title_type][]"}
    #text_input_html_options = { name: "#{@builder.object_name}[title_value][]", value: value[1] }

    contributor_list_choices = ContributorGroupService.new.select_active_options

    select_input_html_options = { name: "#{@builder.object_name}[contributor_list][]"}
    text_input_html_options = { name: "#{@builder.object_name}[contributor_id][]", placeholder: 'Orcid id', value: value[1] }


    output = @builder.select(:contribution_list, contributor_list_choices, { selected: value[0] }, select_input_html_options)
    output += @builder.text_field(:contributor_id, text_input_html_options)
    output
  end


  def collection
    @collection ||= begin
                      # As of this writing, the line below is the only once changed from the
                      # original.
      val = object.send(attribute_name)
      col = val.respond_to?(:to_ary) ? val.to_ary : val
      col.reject { |value| value.to_s.strip.blank? } + ['']
    end
  end

end
=end