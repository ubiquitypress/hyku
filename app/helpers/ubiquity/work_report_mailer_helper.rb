module Ubiquity
  module WorkReportMailerHelper
    def display_work_type(work_type)
      return 'Generic Work' if work_type == 'Work'
      work_type
    end
  end
end
