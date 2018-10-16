module Hyrax
  module Actors
    class UbiquitySharedActor < Hyrax::Actors::BaseActor
      # Override BaseActor to handle attributes which expect a [String] instead of an [Array]
      def apply_save_data_to_curation_concern(env)
        new_attributes = clean_attributes(env.attributes)
        env.curation_concern.attributes.each do |key, val|
          if new_attributes[key].present? && new_attributes[key].is_a?(Array)
            new_attributes[key] = new_attributes[key].first if val.nil? || val.is_a?(String)
          end
        end
        env.curation_concern.attributes = new_attributes
        env.curation_concern.date_modified = TimeService.time_in_utc
      end
    end
  end
end