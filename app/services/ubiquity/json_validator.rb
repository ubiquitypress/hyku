module Ubiquity
  class JsonValidator
    attr_accessor :data
    def self.valid_json?(data)
      !!JSON.parse(data)  if data.class == String
      rescue JSON::ParserError
        false
    end

  end
end
