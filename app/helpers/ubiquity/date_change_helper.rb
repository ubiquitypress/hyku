module  Ubiquity
  module DateChangeHelper

    def parse_date(date, date_part)
       Ubiquity::ParseDate.return_date_part(date, date_part)
    end

  end
end
