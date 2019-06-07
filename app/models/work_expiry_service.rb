class WorkExpiryService < ApplicationRecord
  scope :work_records, -> { where(work_type: "work") }
  scope :file_set_records, -> { where(work_type: "file") }
  scope :less_than_current_time, -> { where("expiry_time <= ?", DateTime.now)}
end
