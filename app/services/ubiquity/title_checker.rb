module Ubiquity
  class TitleChecker

   attr_reader :title, :alternative_title, :model_name

    def initialize(title, alternative_title, model_class)
      @title = title
      @alternative_title = alternative_title
      @model_name = model_class
    end


    def find_title(title)
      data = model_name.constantize.where(title: title).first
    end

    def find_alternative_title(alternative_title)
      data = model_name.constantize.where(alternative_title: alternative_title.reject(&:blank?))
    end

    def get_records
      title_object = find_title(title).try(:title)
      alternative_titles_array = find_alternative_title(alternative_title)
      all_existing_titles = []
      alternative_titles_array.each {|object| all_existing_titles.push(*object.alternative_title)}
      #calling to_a on Active Triple relation
      all_existing_titles = all_existing_titles & alternative_title
      if all_existing_titles && title_object
        all_existing_titles.to_a.push title_object.first
        elsif all_existing_titles
          all_existing_titles.to_a
        elsif  title_object
          title_object.title.to_a
      end
    end

  end
end
