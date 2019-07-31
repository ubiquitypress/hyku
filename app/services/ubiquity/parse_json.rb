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

    def fetch_value_based_on_key(key_field, seperator = nil)
      value_arr = []
      if parsed_json
        parsed_json.map do |hash|
          # we are using the union literal  '|' which is used to combine the unique values of two arrays
          #This means the script is idempotent, which for our use case means that you can re-run it several times without creating duplicates
          value = []
          if hash["#{key_field}_family_name"].present? ||  hash["#{key_field}_given_name"].present?
            value << hash["#{key_field}_family_name"].try(:strip)
            value << hash["#{key_field}_given_name"].try(:strip)
          elsif hash["#{key_field}_organization_name"].present?
            value << hash["#{key_field}_organization_name"].try(:strip)
          end
          value_arr << value.compact.reject(&:blank?).join(', ')
        end
      end
      return value_arr.join(seperator) if seperator.present?
      value_arr
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
