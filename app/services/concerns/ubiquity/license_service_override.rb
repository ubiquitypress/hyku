module Ubiquity
  module LicenseServiceOverride

    def initialize(authority_name, custom_list = [])
      @authority = Qa::Authorities::Local.subauthority_for(authority_name)
      @custom_list = custom_list
    end

  end
end
