module Hyrax
  module Actors
    class UbiquitySharedActor < Hyrax::Actors::BaseActor
      # Override BaseActor to handle attributes which expect a [String] instead of an [Array]
      def apply_save_data_to_curation_concern(env)
        new_attributes = clean_attributes(env.attributes)
        env.curation_concern.attributes.each do |key, val|
          if new_attributes[key].present? && new_attributes[key].is_a?(Array)
            new_attributes[key] = new_attributes[key].first if val.nil? || val.is_a?(String)
            process_json_value(key, new_attributes) if ['creator', 'editor', 'contributor', 'alternate_identifier', 'related_identifier', 'funder'].include? key
          end
        end
        env.curation_concern.attributes = new_attributes
        env.curation_concern.date_modified = TimeService.time_in_utc

      rescue  ActiveFedora::UnknownAttributeError => e
        puts "in ubiquity_shared_actor #{e.inspect}"
      end

      #We are ensuring json fields are saved and the search facet created, if the json  is coming via csv import or other source beside the UI
      def process_json_value(key, new_attributes)
         split_key = key.split('_')
         field_name = split_key.length >= 2 ? split_key.join('_') : split_key.first
         group_field_name  = "#{field_name}_group"
         if new_attributes[key].first.present? && !new_attributes[group_field_name].present?
           new_attributes[group_field_name] = JSON.parse(new_attributes[key].first)
         end
      end

    end
  end
end
