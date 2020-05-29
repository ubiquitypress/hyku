class UbiquityExportCsvDelete < ActiveJob::Base

  def perform
    s3 = Ubiquity::S3Wrapper.new(bucket_name: ENV['S3_BUCKET_NAME'])
    #expired_records.first.delete
    expired = s3.expired_records
    if expired.present?
      expired.map {|item| item.delete}
    end
  end

end
