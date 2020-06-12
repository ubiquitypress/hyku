require 'aws-sdk'
require 'zip'
#
# Usage
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
      @get_options = options
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
      if tenant_name.present? && bucket.present?
        @objects ||= bucket.try(:objects)
        #sort descending ie most recent first
        tenant_records = @objects && @objects.map {|s3_item| s3_item if s3_item.key.include?(@tenant_name) }.compact
        tenant_records && tenant_records.sort_by {|object| -object.try(:data).try(:last_modified).try(:to_i)}
      end
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
      if single_s3_object.present? && csv_data.class != Array
        single_s3_object.put body: csv_data
      elsif csv_data.class == Array && csv_data.present?
        puts "Preparing to zip data with #{csv_data.size} csv strings"
        zip_data
      end
      rescue NameError => e
       puts "#{e.inspect}"
    end

    def zip_data
      archive_name = key.gsub('csv', 'zip')
      puts "Arhcive file name, #{archive_name}"
      obj = single_s3_object(archive_name)

      buffer = Zip::OutputStream.write_buffer do |out|
        csv_data.each_with_index do |value, index|
          new_file_name = (index.to_s + csv_filename)
          puts "Zipped filenames #{new_file_name.inspect}"
          out.put_next_entry(new_file_name)
          out.print  value
        end
      end
      # The write_buffer returns a StringIO and needs to rewind the stream first before read
      buffer.rewind
      csv_record = buffer.read
      obj.put body: csv_record

    end

    def expired_records
      all = all_objects_in_s3bucket
      #return items whose date is not within the past 3 days
      all.map {|item| item unless 3.days.ago <= item.data.last_modified}.compact
    end

  end
end
