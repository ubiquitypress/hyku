module Ubiquity
  class FetchTenantUrl

    def initialize(object)
      @account_cname = object.try(:account_cname)
      @id = object.try(:id)
      @work_type = object.try(:human_readable_type)
    end

    def process_url
      return nil if @account_cname.nil?
      work_type = @work_type.downcase.pluralize
      if @account_cname.split('.').include? 'localhost'
        "http://#{@account_cname}:3000/concern/#{work_type}/#{@id}"
      else
        "https://#{@account_cname}/concern/#{work_type}/#{@id}"
      end
    end
  end
end
