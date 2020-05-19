#example  of usage
# k = Ubiquity::ParseTenantWorkSettings.new('http://university-demo.localhost:8080/dashboard/my/collections?locale=en')
# k.redirect_url

module Ubiquity
  class ParseTenantWorkSettings
    attr_accessor :url, :name

    #value can be a url or the the value of an account.name
    def initialize(value)
      set_url(value)
      if url.nil? && value.present?
        @name = value.split('.').first
      end
    end

    def get_tenant_subdomain
      if url.present? && url.host.present? && url.host.class == String
        url.host.split('.').first
      elsif url.nil?  && name.present?
        name
      end
    end

    def redirection_settings_hash
      subdomain = get_tenant_subdomain
      if tenant_settings_hash.present?
        tenant_settings_hash[subdomain]["live"]
      end
    end

    #returns something like {"url"=>"https://demo.pacific.us-frontend.ubiquityrepository.website"}
    def redirect_subdomain_url_hash
      if get_tenant_subdomain.present? && redirection_settings_hash.present?
        redirection_settings_hash[get_tenant_subdomain]
      end
    end

    def redirect_url
      if redirect_subdomain_url_hash.present?
        "https://#{redirect_subdomain_url_hash}"
      end
    end

    def tenant_settings_hash
      is_valid_json = Ubiquity::JsonValidator.valid_json?(tenant_settings_json)
      if is_valid_json
        JSON.parse(tenant_settings_json)
      end
     end

     def get_per_account_settings_value_from_tenant_settings(settings_key)
       account_settings_hash = tenant_settings_hash
       subdomain = get_tenant_subdomain
       account_settings_hash && account_settings_hash[subdomain] && account_settings_hash[subdomain][settings_key]
     end

     def get_settings_value_from_tenant_settings(settings_key)
       settings_hash = tenant_settings_hash
       settings_hash && settings_hash[settings_key]
     end

     def get_nested_settings_value_from_tenant_settings(settings_key1, settings_key2)
       work_settings_hash = tenant_settings_hash
       work_settings_hash && work_settings_hash[settings_key1] && work_settings_hash[settings_key1][settings_key2]
     end


     private

     def tenant_settings_json
       settings = ENV['TENANTS_SETTINGS']
     end

     def set_url(value)
       parse_url = URI.parse(value)
       if (parse_url.kind_of?(URI::HTTPS) || parse_url.kind_of?(URI::HTTP))
         @url = parse_url
       else
         @url = nil
       end
     end
  end
end
