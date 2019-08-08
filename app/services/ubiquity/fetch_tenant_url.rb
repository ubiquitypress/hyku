module Ubiquity
  class FetchTenantUrl

    def initialize(object)
      @account_cname = object.try(:account_cname)
      @id = object.try(:id)
      @work_type = object.try(:has_model).try(:first).to_s
      @is_collection = object.collection?
    end

    def process_url
      return nil if @account_cname.nil?
      work_type = @work_type.tableize
      if @account_cname.split('.').include? 'localhost'
        @is_collection ? "http://#{@account_cname}:3000/#{work_type}/#{@id}" : "http://#{@account_cname}:3000/concern/#{work_type}/#{@id}"
      else
        @is_collection ? "https://#{@account_cname}/#{work_type}/#{@id}" : "https://#{@account_cname}/concern/#{work_type}/#{@id}"
      end
    end
  end
end
