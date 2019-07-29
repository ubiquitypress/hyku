module Ubiquity
  module WorkReportMailerHelper
    def display_work_type(work_type)
      return 'Generic Work' if work_type == 'Work'
      work_type
    end

    def display_email_type_message(email_type)
      case email_type
      when 'weekly_email_list'
        Date.today.to_s + ' till last week'
      when 'monthly_email_list'
        Date.today.to_s + ' till last month'
      else
        Date.today.to_s + ' till last Year'
      end
    end

  end
end
