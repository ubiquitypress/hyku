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
        @name = value
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
      if tenant_work_settings_hash.present?
        tenant_work_settings_hash["redirect_show_link"]
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
        redirect_subdomain_url_hash['url']
      end
    end

    def tenant_work_settings_hash
      is_valid_json = Ubiquity::JsonValidator.valid_json?(tenant_work_settings_json)
      if is_valid_json
        JSON.parse(tenant_work_settings_json)
      end
    end

    private

    def tenant_work_settings_json
      settings = ENV['TENANTS_WORK_SETTINGS']
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
