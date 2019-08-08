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
      concern_url = @is_collection ? 'dashboard' : 'concern'
      if @account_cname.split('.').include? 'localhost'
        "http://#{@account_cname}:3000/#{concern_url}/#{work_type}/#{@id}"
      else
        "https://#{@account_cname}/#{concern_url}/#{work_type}/#{@id}"
      end
    end
  end
end
