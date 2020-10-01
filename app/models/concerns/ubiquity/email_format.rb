module Ubiquity
  module EmailFormat
    extend ActiveSupport::Concern

    included do
      # validate :must_have_valid_email_format
    end

    def current_account_name
      account = Account.find_by(tenant: Apartment::Tenant.current)
      account.name if account
    end

    def get_subdomain
      current_account_name.split('.').first if current_account_name
    end

    def get_tenant_settings
      json_data = ENV['TENANTS_SETTINGS']
        if json_data.present? && json_data.class == String
        JSON.parse(json_data)
      end
    end

    def must_have_valid_email_format
      subdomain = get_subdomain
      settings_hash = get_tenant_settings
      format = settings_hash[subdomain]['email_format'] || settings_hash['email_format']
      if format.present?
        email_format = '@' + email.split('@')[-1]
        errors.add(:email, "Email must contain #{format[0]}") unless format.include? email_format
      end
    end
  end
end
