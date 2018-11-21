module  Ubiquity
  module DateChangeHelper
    
    MONTHS = (1..12).to_a.freeze
    DAYS = (1..31).to_a.freeze
    YEARS =  ((Date.today.year - 200)..(Date.today.year)).to_a.reverse.freeze

    def days_array
      ApplicationHelper::DAYS
    end

    def months_array
      ApplicationHelper::MONTHS
    end

    def years_array
      ApplicationHelper::YEARS
    end

    def parse_date(date, date_part)
      if date.present? && date_part == 'year'
        Date.parse(date).try(:strftime, "%Y").to_i
      elsif date.present? && date_part == 'month'
        Date.parse(date).try(:strftime, "%m").to_i
      elsif date.present? && date_part == 'day'
        Date.parse(date).try(:strftime, "%d").to_i
      end
    end

  end
end
