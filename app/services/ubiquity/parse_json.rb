module Ubiquity
  class ParseJson
    attr_accessor :data

    def initialize(json_data)
      @data = json_data
    end

    def parsed_json
      if @data.present? && @data.class == Array && @data.first.class == String
        JSON.parse(@data.first)
      elsif @data.class == String
        JSON.parse(@data)
      end
    end

    def data
      transform_data(parsed_json) if parsed_json.present?
    end

    def fetch_value_based_on_key(key_field)
      value_arr = []
      if parsed_json
        parsed_json.map do |hash|
          # we are using the union literal  '|' which is used to combine the unique values of two arrays
          #This means the script is idempotent, which for our use case means that you can re-run it several times without creating duplicates
          value = []
          value |= [hash["#{key_field}_family_name"].to_s]
          value |= [', '] if hash["#{key_field}_family_name"].present? && hash["#{key_field}_given_name"].present?
          value |= [hash["#{key_field}_given_name"].to_s]
          value |= [hash["#{key_field}_organization_name"]]
          value_arr << value.reject(&:blank?).join
        end
      end
      value_arr
    end

    def separate_creator_with_semicolon
      if parsed_json.present?
        value_arr = []
        parsed_json.map do |hash|
          value = []
          value << hash['creator_family_name']  if hash['creator_family_name'].present?
          value << hash['creator_given_name'] if hash['creator_given_name'].present?
          value << hash["creator_organization_name"] if hash["creator_organization_name"].present?
          value_arr << value.reject(&:blank?).join(', ')
        end
        value_arr.join('; ')
      end
    end

    def creator_for_rif_template
      return nil if parsed_json.blank?
      value_arr = []
      parsed_json.map do |hash|
        value = []
        if hash['creator_family_name'].present? ||  hash['creator_given_name'].present?
          value << "#{hash['creator_family_name']}, #{hash['creator_given_name']}"
        elsif hash["creator_organization_name"].present?
          value << hash["creator_organization_name"]
        end
        value_arr << value.reject(&:blank?).join(', ')
      end
      value_arr.join('; ')
    end

    def editor_for_rif_template
      return nil if parsed_json.blank?
      value_arr = []
      parsed_json.map do |hash|
        value = []
        if hash['editor_family_name'].present? ||  hash['editor_given_name'].present?
          value << "#{hash['editor_family_name']}, #{hash['editor_given_name']}"
        elsif hash["editor_organization_name"].present?
          value << hash["editor_organization_name"]
        end
        value_arr << value.reject(&:blank?).join(', ')
      end
      value_arr.join('; ')
    end

    def transform_data(parsed_json)
      value_arr = []
      parsed_json.map do |hash|
        # we are using the union literal  '|' which is used to combine the unique values of two arrays
        #This means the script is idempotent, which for our use case means that you can re-run it several times without creating duplicates
        value = []
        value |= [hash["creator_family_name"].to_s]
        value |= [', '] if hash["creator_family_name"].present? && hash["creator_given_name"].present?
        value |= [hash["creator_given_name"].to_s]
        value |= [hash["creator_organization_name"]]
        value_arr << value.reject(&:blank?).join
      end
      value_arr
    end
  end
end
