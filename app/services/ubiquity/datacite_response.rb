module Ubiquity
  class DataciteResponse
    attr_accessor :api_response, :error
    attr_reader :raw_http_response, :attributes
    # parsed_response_hash is httparty response body
    def initialize(response_hash: nil, result: nil, error: nil)
      @api_response = response_hash
      @raw_http_response = result
      @error = error
      @attributes = response_hash['data']['attributes'] if !response_hash.nil? && response_hash.class == Hash
    end

    def title
      attributes['title']
    end

    def date_published_year
      attributes['published']
    end

    def abstract
      attributes['description']
    end

    def version
      attributes.dig('version')
    end

    def license
      attributes.dig('license')
    end

    def doi
      attributes.dig('identifier')
    end

    def creator
      creator_group = attributes.dig('author')
      if (creator_group.first.keys.include? "given") || (creator_group.first.keys.include? "family")
        creator_with_seperated_names(creator_group)
      else
        creator_without_seperated_names(creator_group)
      end
    end

    # [{"relation-type-id"=>"Documents", "related-identifier"=>"https://doi.org/10.5438/0013"}, {"relation-type-id"=>"IsNewVersionOf", "related-identifier"=>"https://doi.org/10.5438/0010"}]
    def related_identifier
      related_group = attributes['related-identifiers']
      related_group.map do |hash|
        {
          "relation_type" =>  hash["relation-type-id"],
          "related_identifier" => hash["related-identifier"],
          "related_identifier_type" => 'DOI'
        }
      end
    end

    def auto_populated_fields
      fields = []
      fields << 'title' if title.present?
      fields << 'creator' if creator.present?
      fields << "published" if date_published_year.present?
      fields << 'DOI' if doi.present?
      fields << 'related_identifier' if related_identifier.present?
      fields << 'abstract' if abstract.present?
      fields << 'licence' if (license.present? && licence_present?.include?(license))
      # fields << 'version' if version.present?

      "The following fields were auto-populated - #{fields.to_sentence}"
    end

    def data
      if error.present?
        { 'error' => error }
      else
        {
          'related_identifier_group': related_identifier,
          "title": title, "published_year": date_published_year,
          "abstract": abstract, "version": version,
          "creator_group": creator, "license": license,
          "auto_populated": auto_populated_fields,
          "doi": doi
        }
      end
    end

     private

      def creator_without_seperated_names(data)
        new_group = data.map {|hash| hash['literal']}
        new_creator_group = []
        new_group.each_with_index do |data, index|
          new_data = data.split
          creator_given_name = new_data.shift
          creator_family_name = new_data.join(' ')
          creator_position = index
          creator_name_type = 'Personal'
          hash = {'creator_given_name' =>  creator_given_name, 'creator_family_name' => creator_family_name,
                  'creator_position' => creator_position, 'creator_name_type' => creator_name_type
                  }
            new_creator_group << hash
        end
        new_creator_group
      end

      def creator_with_seperated_names(data)
        new_creator_group = []
        data.each_with_index do |hash, index|
          hash = {
            "creator_given_name" =>  hash["given"],
            "creator_family_name" => hash["family"],
            "creator_name_type" => 'Personal',
            "creator_position" => index
          }
          new_creator_group << hash
        end
        new_creator_group
      end

    #fetches list licences from config/authorities/licenses.yml
    # returns each record in the form of ["CC BY 4.0 Attribution", "https://creativecommons.org/licenses/by/4.0/"]
    # we are returning just the last part eg [ "https://creativecommons.org/licenses/by/4.0/"]
    def licence_present?
      licences = Hyrax::LicenseService.new.select_all_options
      licences.map(&:last)
    end
  end
end
