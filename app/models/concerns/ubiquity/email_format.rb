module Ubiquity
  module EmailFormat
    extend ActiveSupport::Concern

    included do
      validate :must_have_valid_email_format
    end

    def get_tenant_work_settings
      json_data = ENV['TENANTS_WORK_SETTINGS']
        if json_data.present? && json_data.class == String
        JSON.parse(json_data)
      end
    end

    def must_have_valid_email_format
      format = get_tenant_work_settings['email_format']
      if format.present?
        errors.add(:email, "Email must contain #{format}") unless email.include? format
      end
    end
  end
end
