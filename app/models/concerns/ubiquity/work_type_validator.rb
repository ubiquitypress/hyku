module Ubiquity
  module WorkTypeValidator
    extend ActiveSupport::Concern

    validate :validator_work_type  #if get_work_list.present?

    def validator_work_type
      if get_work_list.include?('ArticleWork')
        errors.add('ArticleWork', "ArticleWork type is not an allowed type")
      end
    end

    def get_work_list
      data = ENV["TENANTS_WORK_SETTINGS"]
      parsed_date = JSON.parse(data)
      work_types_array = parsed_d["registered_curation_concern_types"].split(',')
    end

  end
end
