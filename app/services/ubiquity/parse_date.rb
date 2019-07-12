module Ubiquity
  class ParseDate
    attr_reader :data, :date_field

    def initialize(date_data, date_field_name)
      @date_field = date_field_name
      @data = date_data.split('||')
    end

    def process_dates
      return_values = []
      @data.map do |date|
        return_values << transform_date_group(date)
      end
      return_values
    end

    def self.return_date_part(date, date_part)
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

    private

    def transform_date_group(date)
      date_parts =  date.split('-')

      year = "#{date_field}_year"
      month = "#{date_field}_month"
      day = "#{date_field}_day"

      #returns a hash in the form {"date_published_year"=>"2017", "date_published_month"=>"02", "date_published_day"=>"02"}
      Hash[[ [year,  date_parts.first], [month,  date_parts[1]], [day,  date_parts.last]  ]]

    end

  end
end
