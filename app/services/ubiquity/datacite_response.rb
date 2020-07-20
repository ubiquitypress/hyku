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
      if  attributes['titles'].present?
        attributes['titles'][0]['title']
      end
    end

    def date_published_year
      attributes['published']
    end

    def abstract
      if attributes['descriptions'].present? && attributes['descriptions'][0]['description'].present?
          ActionView::Base.full_sanitizer.sanitize attributes['descriptions'][0]['description']
      end
    end

    def version
      attributes.dig('version')
    end

    def funder
      if attributes.dig('fundingReferences').present?
        # attributes.dig('fundingReferences').first["funderName"]
        attributes["fundingReferences"].each_with_index.map do |hash_funder, index|
           {
             "funder_name" => hash_funder["funderName"], 'funder_doi' => hash_funder["funderIdentifier"],
             'funder_award' => [hash_funder["awardNumber"]], 'funder_position' => index }
        end

      end
    end

    def license
      license_record = attributes.dig("rightsList")
      if license_record.present?
        extract_license(license_record)
      end
    end

    def doi
      attributes.dig('doi')
    end

    def official_url
      identifiers_array = attributes.dig('identifiers')
      result = identifiers_array.map do |hash|
        hash['identifier'] if hash.has_value?('URL') || hash['identifier'] if hash.has_value?('DOI')
      end
      result.compact.first
    end

    def publisher
      attributes.dig('publisher')
    end

    def creator
      creator_group = attributes.dig('creators')
      if creator_group.present?
        build_json_fields(creator_group, 'creator')
      end
    end

    def build_json_fields(records, field_name)
      new_record_group = []
      records.each_with_index do |hash, index|
        if hash["nameType"] == "Personal"
          record =   json_with_personal_name_type(field_name, hash, index)
        elsif hash["nameType"] == "Organizational"
          record = json_with_organisation_name_type( field_name, hash, index)
        end
         new_record_group << record
      end
      new_record_group
    end

    def contributor
      contributor_group = attributes.dig('contributors')
      if contributor_group.present?
        build_json_fields(contributor_group, 'contributor')
      end
    end

    def related_identifier
      related_group = attributes['relatedIdentifiers']
      if related_group.present?
        related_group.map do |hash|
          {
            "relation_type" =>  hash['relationType'],
            "related_identifier" => hash[ "relatedIdentifier"],
            "related_identifier_type" => hash["relatedIdentifierType"]
          }
         end
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
          "publisher": publisher, "official_url": official_url,
          "funder": funder
        }
      end
    end

    private

    def return_license(license_result, url_inactive_collection, regex_url_exp)
      if license_result != nil
        license_result
      else
        object = {}
        label = attributes.dig("rightsList").last["rights"].split(':')[1]
        license_result = url_inactive_collection.select { |e| e.match regex_url_exp }.first
        object = {
        "license": license_result,
        "active": false,
        "label": label
        }
        object
      end
    end

    def json_with_personal_name_type(field_name, hash, index)
      {
        "#{field_name}_given_name" =>  hash["givenName"],
        "#{field_name}_family_name" => hash["familyName"],
        "#{field_name}_orcid" => extract_name_identifiers(hash['nameIdentifiers'], "ORCID"),
        "#{field_name}_isni" => extract_name_identifiers(hash['nameIdentifiers'], "ISNI"),
        "#{field_name}_name_type" => hash['nameType'],
        "#{field_name}_position" => index
      }
    end

    def json_with_organisation_name_type(field_name, hash, index)
      remap_organization = {'Organization' => 'Organisation'}
      {
        "#{field_name}_isni" => extract_name_identifiers(hash['nameIdentifiers'], "ISNI"),
        "#{field_name}_ror" => extract_name_identifiers(hash['nameIdentifiers'], "ROR"),
        "#{field_name}_organization_name" => hash["name"],
        "#{field_name}_name_type" => 'Organisational',
        "#{field_name}_position": index
      }
    end

    def extract_name_identifiers(array_of_identifiers, type)
      if  array_of_identifiers.present?
        identifier = array_of_identifiers.map do |hash_idenifier|
          if hash_idenifier["nameIdentifierScheme"] == type
            hash_idenifier['nameIdentifier']
          elsif hash_idenifier["nameIdentifierScheme"] == type
            hash_idenifier['nameIdentifier']
          elsif hash_idenifier["nameIdentifierScheme"] == type
            hash_idenifier['nameIdentifier']
          end
        end
      end
      identifier.try(:first).presence
    end

    def extract_license(license_records)
      license_records.map do  |license_item|
        if license_item["rightsUri"].present?
          url_array = license_item["rightsUri"].split('/')
          url_active_collection = Hyrax::LicenseService.new.select_active_options.map(&:last)
          url_all_collection = Hyrax::LicenseService.new.select_all_options.map(&:last)
          url_inactive_collection = url_all_collection - url_active_collection
          url_array.pop if url_array.last == 'legalcode'
          url_array.shift(2) # Removing the http, https and // part in the url
          regex_url_str = "(?:http|https)://" + url_array.map { |ele| "(#{ele})" }.join('/')
          regex_url_exp = Regexp.new regex_url_str
          license_result = url_active_collection.select { |e| e.match regex_url_exp }.first
          return_license(license_result, url_inactive_collection, regex_url_exp)
        end
      end.compact
    end

  end
end
