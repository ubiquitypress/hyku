module Ubiquity
  class DataciteResponse
    attr_accessor :api_response, :error
    attr_reader :raw_http_response, :attributes

    def initialize(response_hash: nil, result: nil, error: nil)
      @api_response = response_hash
      @raw_http_response = result
      @error = error
      @attributes = response_hash['data']['attributes'] if !response_hash.nil? && response_hash.class == Hash
    end

    def title
      attributes['titles'][0]['title']
    end

    def date_published_year
      attributes['published']
    end

    def abstract
      attributes['descriptions'][0]['description']
    end

    def version
      attributes.dig('version')
    end

    def license
      if attributes.dig("rightsList").present?
        url_array = attributes.dig("rightsList").last["rightsUri"].split('/')
        url_collection = Hyrax::LicenseService.new.select_active_options.map(&:last)
        url_array.pop if url_array.last == 'legalcode'
        url_array.shift(2) # Removing the http, https and // part in the url
        regex_url_str = "(?:http|https)://" + url_array.map { |ele| "(#{ele})" }.join('/')
        regex_url_exp = Regexp.new regex_url_str
        url_collection.select { |e| e.match regex_url_exp }.first
      end
    end

    def doi
      attributes.dig('doi')
    end

    def publisher
      attributes.dig('publisher')
    end

    def creator
      creator_group = attributes.dig('creators')
      if creator_group.first.keys.to_set.intersect? ["nameType", :nameType].to_set
        json_with_personal_name_type('creator', creator_group)
      else
        json_with_organisation_name_type('creator', creator_group)
      end
    end

    def contributor
      contributor_group = attributes.dig('contributors')
      if contributor_group.first.keys.to_set.intersect? ["nameType", :nameType].to_set
        json_with_personal_name_type('contributor', contributor_group)
      else
        json_with_organisation_name_type('contributor', contributor_group)
      end
    end

    # [{"relation-type-id"=>"Documents", "related-identifier"=>"https://doi.org/10.5438/0013"}, {"relation-type-id"=>"IsNewVersionOf", "related-identifier"=>"https://doi.org/10.5438/0010"}]
    def related_identifier
      related_group = attributes['relatedIdentifiers']
      related_group.map do |hash|
        {
          "relation_type" =>  hash["relation-type-id"],
          "related_identifier" => hash["related-identifier"],
          "related_identifier_type" => 'DOI'
        }
      end
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
          "doi": doi, "contributor_group": contributor,
          "publisher": publisher
        }
      end
    end

  private

  def json_with_personal_name_type(field_name, data)
    new_value_group = []
    data.each_with_index do |hash, index|
      hash = {
        "#{field_name}_given_name" =>  hash["givenName"],
        "#{field_name}_family_name" => hash["familyName"],
        "#{field_name}_name_type" => 'Personal',
        "#{field_name}_position" => index
      }
      new_value_group << hash
    end
    new_value_group
  end

  def json_with_organisation_name_type(field_name, data)
        new_value_group = []
        data.each_with_index do |hash, index|
          hash = {
                   "#{field_name}_organization_name" =>  hash["name"],
                   "#{field_name}_name_type" => 'Organisational',
                   "#{field_name}_position" => index
                  }
          new_value_group << hash
        end
        new_value_group
    end
  end
end
