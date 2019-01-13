module  Ubiquity
  module DateChangeHelper
    
    MONTHS = (1..12).to_a.map { |n| n.to_s.rjust(2, '0')}.freeze
    DAYS = (1..31).to_a.map { |n| n.to_s.rjust(2, '0')}.freeze
    CURRENT_YEAR_PLUS2 = (Date.today.year) + 2
    YEARS = ((Date.today.year - 200)..(CURRENT_YEAR_PLUS2)).to_a.reverse.freeze

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
      return nil if date.blank?
      split_date = date.split('-') if date.respond_to?(:split)
      if date_part == 'year'
        return date.strftime("%Y") if date.respond_to?(:strftime)
        split_date[0]
      elsif date_part == 'month'
        return date.strftime("%m") if date.respond_to?(:strftime)
        split_date[1] if split_date.length > 1
      elsif date_part == 'day'
        return date.strftime("%d") if date.respond_to?(:strftime)
        split_date[2] if split_date.length == 3
      end
    end

  end
end
