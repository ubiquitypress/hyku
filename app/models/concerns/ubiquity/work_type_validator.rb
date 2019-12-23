module Ubiquity
  module WorkTypeValidator
    extend ActiveSupport::Concern

    included do
      validate :validator_work_type  if :get_work_list.present?
    end

    def validator_work_type
      if not get_work_list.include?(self.class)
        errors.add("#{self.class}", "is not in your list of work types") 
      end
    end

    def get_work_list
      data = ENV["TENANTS_WORK_SETTINGS"]
      parsed_data = data.presence && JSON.parse(data)
      work_types_array = parsed_data.presence && parsed_data["registered_curation_concern_types"].presence && parsed_data["registered_curation_concern_types"].split(',')
      work_types_array.present? ? work_types_array.map {|i| i.classify.constantize} : Hyrax.config.curation_concerns
    end

  end
end
