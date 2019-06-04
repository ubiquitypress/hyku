module Ubiquity
  class TitleChecker

   attr_reader :title, :alternative_title, :model_name

    def initialize(title, alternative_title, model_class)
      @title = title
      @alternative_title = alternative_title
      @model_name = model_class
    end

    def get_records
      ary = [title] + alternative_title
      final_ary = []
      ary.each do |title|
        title_data = model_name.constantize.where(title: title)
        if title_data.present?
          final_ary << title
        else
          alternative_title_data = model_name.constantize.where(alt_title: title)
          final_ary << title if alternative_title_data.present?
        end
      end
      final_ary.reject(&:blank?)
    end

  end
end
