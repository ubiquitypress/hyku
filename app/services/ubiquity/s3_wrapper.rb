require 'aws-sdk'
#bucket eg ubiquity-sampler
#filename 'lib/article4.csv
# csv = Article.to_csv
#s = Ubiquity::S3Wrapper.new(csv_data: csv, bucket_name: 'ubiquity-sampler' , csv_filename: 'article4.csv', tenant_name: 'lib':)
# u = s.upload_to_s3
#u.successful?
# s.download_url
#
module Ubiquity
  class S3Wrapper
    attr_accessor :csv_data, :bucket_name, :bucket, :csv_filename, :tenant_name,  :get_options
    def initialize(csv_data: nil, bucket_name: , csv_filename: nil, tenant_name: nil,  options: {})
      @get_options = options  #options.presence || {}
      @csv_data = csv_data
      @bucket_name = bucket_name
      @csv_filename = csv_filename
      @tenant_name = tenant_name
    end

    def self.client
      Aws::S3::Resource.new(
        region: ENV['S3DIRECT_REGION'],
        access_key_id: ENV['AWS_ACCESS_KEY_ID'],
        secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
      )
    end

    def client
      Aws::S3::Resource.new(
        region: ENV['S3DIRECT_REGION'],
        access_key_id: ENV['AWS_ACCESS_KEY_ID'],
        secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
      )
    end

    def bucket
      begin
        @bucket ||= client.create_bucket(bucket: bucket_name) if bucket_name.present?
      rescue Aws::S3::Errors::BucketAlreadyOwnedByYou => e
        #puts "#{e.inspect}"
        @bucket ||= client.bucket(bucket_name) if bucket_name.present?
      end
    end

    def key
      #csv_filename
      if tenant_name.present? && csv_filename.present?
        tenant_name + '/' + csv_filename
      end
    end

    def all_objects_in_s3bucket
      @objects ||= bucket.try(:objects)
      #sort descending ie most recent first
      @objects && @objects.sort_by {|object| -object.try(:data).try(:last_modified).try(:to_i)}

      rescue Aws::S3::Errors::BucketAlreadyExists => e
        puts "#{e.inspect}"
    end

    def object_metadata(object)
       object.try(:data)
    end

    def single_s3_object(filename = nil)
      new_key = filename.presence || key
      #note about .csv do we add it
      if new_key.present?
        bucket && bucket.object(new_key)
      end
    end

   #259200  seconds is 3 days
    def download_url(filename = nil)
      if filename.present?
        new_object = single_s3_object(filename)
        new_object && new_object.presigned_url(:get, expires_in: 90)
      end
    end

    def upload_to_s3
      if single_s3_object.present?
        single_s3_object.put body: csv_data
      end
      rescue NameError => e
       puts "#{e.inspect}"
    end

    def expired_records
      all = all_objects_in_s3bucket
      #return items whose date is not within the past 3 days
      all.map {|item| item unless 3.days.ago <= item.data.last_modified}.compact
    end

  end
end
