module Ubiquity
  module SolrSearchDisplayHelpers

    #doc is a solr document passed in from the view file
    def display_json_fields(doc, field_name)
      attr_name = field_name.split('_').first
      field_data =  doc[field_name] if (doc[field_name].present?)
      field = JSON.parse(field_data.first) if field_data.present?
      render "shared/ubiquity/search_display/show_array_hash", array_of_hash: field, attr_name: attr_name
    end

    # method below was worked out reading http://jessiekeck.com/customizing-blacklight/metadata_fields/
    def display_multi_part_fields_in_search(options={})
      field = JSON.parse(options[:value][0]).map do |hash|
        content = []
        hash.each_value { |v| content << v }
        content
      end
      field.join(', ')
    end

    def human_readable_resource_type(options={})
      label = options[:value]
      new_label = label.first.split.drop(1)
      new_label = new_label.drop(1) if new_label.first == "default"
      new_label.join(' ')
    end

    private

      def pass_model(options)
        my_model = options[:document].hydra_model.to_s
        my_id = options[:document].id
        presento ||= Ubiquity::SolrModelWrapper.new(my_model, my_id)
      end
  end
end
