module Ubiquity
  class ParseJson
    attr_accessor :data

    def initialize(json_data)
      @data = json_data
    end

    def data
      if @data.class == Array
        parsed_json = JSON.parse(@data.first) if @data.first.class == String
        transform_data(parsed_json)
      elsif  @data.class == String
        parsed_json = JSON.parse(@data) if @data.class == String
        transform_data(parsed_json)
      end

    end

    def transform_data(parsed_json)
      value = []
      record = parsed_json.map do |hash|
        value << (hash["creator_given_name"].to_s + ' ' + hash["creator_family_name"].to_s)
        value << hash["creator_organization_name"]
        value
      end
      value.reject(&:blank?).compact
    end

  end
end
