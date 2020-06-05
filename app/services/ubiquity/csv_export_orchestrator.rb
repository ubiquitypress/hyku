module Ubiquity
  class CsvExportOrchestrator
    attr_accessor :csv_data, :bucket_name, :csv_filename, :tenant_name, :requester, :options, :s3_key
    def initialize(csv_data: nil, csv_filename:, tenant_name:, requester: , options: {})
      @csv_data = csv_data
      @bucket_name =  ENV['S3_BUCKET_NAME']  #tenant_name
      @csv_filename = csv_filename
      @tenant_name = tenant_name
      @requester = requester
      @options = options
    end

    def s3_key
      "#{tenant_name}_#{csv_filename}.csv"
    end

    def s3_wrapper_object
      @s3_wrapper_object ||= Ubiquity::S3Wrapper.new(csv_data: csv_data, bucket_name: bucket_name , tenant_name: tenant_name, csv_filename: "#{csv_filename}.csv")
    end

   def upload_to_s3
     @upload_to_s3 ||= s3_wrapper_object.upload_to_s3
   end

   def is_upload_successful?
     @upload_to_s3.successful?
   end

   def send_download_ready_notification
     AccountElevator.switch!(tenant_name)
     if is_upload_successful? && requester.present?
       user = User.find_by(email: requester) || User.find_by(id: requester)
       url = get_tenant_url
       user.send_message(user, "The CSV can be <a href=#{url}> downloaded from the Export Metadata page </a>", "CSV produced for #{csv_filename} export request")
     end
   end

   def s3_download_url
     s3_wrapper_object.download_url
   end

   def redis_storage_object
     success =  @upload_to_s3.successful?

     if !success
       options = {'successful' =>  success, "date_of_original_request"=> Time.now}
       @redis_storage_object ||= Ubiquity::RedisStorage.new(tenant_name: tenant_name, export_name: csv_filename, requester: requester, options: options)

     end
   end

   def save_to_redis
     if redis_storage_object
       redis_storage_object.save
     end
   end

   private

   def get_tenant_url
     if tenant_name.include? 'localhost'
       "http://#{tenant_name}:8080/admin/exports?locale=en#download-csv"
     else
       "https://#{tenant_name}/admin/exports?locale=en#download-csv"
     end

   end

  end
end
