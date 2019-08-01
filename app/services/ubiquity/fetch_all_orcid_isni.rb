module Ubiquity
  class FetchAllOrcidIsni

    def initialize(object)
      @contributor = object.try(:contributor)
      @creator = object.try(:creator)
      @editor = object.try(:editor)
    end

    def fetch_data
      final_data = []
      ['contributor', 'creator', 'editor'].each do |json_data_var|
        json_data = instance_variable_get("@#{json_data_var}")
        next if json_data.blank?
        JSON.parse(json_data.first).each do |record_hash|
          a = []
          a << "#{json_data_var.capitalize} ORCID : " + record_hash["#{json_data_var}_orcid"].try(:strip) if record_hash["#{json_data_var}_orcid"].present?
          a << "#{json_data_var.capitalize} ISNI : " + record_hash["#{json_data_var}_isni"].try(:strip) if record_hash["#{json_data_var}_isni"].present?
          final_data << a.join(', ')
        end
      end
      final_data.compact
    end
  end
end
