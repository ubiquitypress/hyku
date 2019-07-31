module Ubiquity
  module WorkReportMailerHelper
    def display_work_type(work_type)
      return 'Generic Work' if work_type == 'Work'
      work_type
    end

    def display_tenant_link(tenant_cname)
      if tenant_cname.present?
        if tenant_cname.split('.').include? 'localhost'
          "http://#{tenant_cname}:3000"
        else
          "https://#{tenant_cname}"
        end
      end
    end
  end
end
