module Ubiquity
  module EmailFormat
    extend ActiveSupport::Concern

    included do
      validate :must_have_valid_email_format
    end

    def get_tenant_settings
      json_data = ENV['TENANTS_SETTINGS']
        if json_data.present? && json_data.class == String
        JSON.parse(json_data)
      end
    end

    def must_have_valid_email_format
      format = get_tenant_settings['email_format']
      if format.present?
        email_format = '@' + email.split('@')[-1]
        errors.add(:email, "Email must contain #{format[0]}") unless format.include? email_format
      end
    end
  end
end
