module Ubiquity
  class ParseJson
    attr_accessor :data

    def initialize(json_data)
      @data = json_data
    end

    def data
      parsed_json = if @data.class == Array && @data.first.class == String
                      JSON.parse(@data.first)
                    elsif @data.class == String
                      JSON.parse(@data)
                    end
      transform_data(parsed_json)
    end

    def transform_data(parsed_json)
      value = []
      record = parsed_json.map do |hash|
        # we are using the union literal  '|' which is used to combine the unique values of two arrays
        #This means the script is idempotent, which for our use case means that you can re-run it several times without creating duplicates
        value |= [(hash["creator_given_name"].to_s + ' ' + hash["creator_family_name"].to_s)]
        value |= [hash["creator_organization_name"]]
        value
      end
      value.reject(&:blank?).compact
    end

  end
end
