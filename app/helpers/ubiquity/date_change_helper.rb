module  Ubiquity
  module DateChangeHelper

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
