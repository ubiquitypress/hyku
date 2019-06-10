module Ubiquity
  class ExpiryService
    # adds get_visibility_after_expiration and compare_visibility?
    include Ubiquity::ExpiryUtil

    def release_expired_works
      WorkExpiryService.work_records.less_than_current_time.each do |work|
        UbiquityWorkExpiryJob.perform_later(work.work_id, work.tenant_name, 'work')
      end
      WorkExpiryService.file_set_records.less_than_current_time.each do |work|
        UbiquityWorkExpiryJob.perform_later(work.work_id, work.tenant_name, 'file')
      end
    end
  end
end
