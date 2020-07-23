module Ubiquity
  class CrossrefResponse
    attr_reader :error, :attributes
    def initialize(response_hash = nil)
      @error = error
      @attributes = response_hash['message']
    end

    def title
      attributes['title']
    end

    def abstract
      # For removing the Jat tags inside the abstract
      ActionView::Base.full_sanitizer.sanitize attributes['abstract']
    end

    def version
      attributes['message-version']
    end

    def date_published_year
      date_hash = attributes['published-online'].presence || attributes['published-print']
      return date_hash['date-parts'].first[0] if date_hash
    end

    def date_published_month
      date_hash = attributes['published-online'].presence || attributes['published-print']
      return date_hash['date-parts'].first[1] if date_hash
    end

    def license
      return nil if attributes['license'].blank?
      url_array = fetch_url_from_response.split('/')
      url_collection = Hyrax::LicenseService.new.select_active_options.map(&:last)
      url_array.pop if url_array.last == 'legalcode'
      url_array.shift(2) # Removing the http, https and // part in the url
      regex_url_str = "(?:http|https)://" + url_array.map { |ele| "(#{ele})" }.join('/')
      regex_url_exp = Regexp.new regex_url_str
      url_collection.select { |e| e.match regex_url_exp }.first
    end

    def date_published_day
      date_hash = attributes['published-online'].presence || attributes['published-print']
      return date_hash['date-parts'].first[2] if date_hash
    end

    def issn
      return nil if attributes['issn-type'].blank?
      print_value = attributes['issn-type'].detect { |h| h['type'] == 'print' }
      return print_value['value'] if print_value
    end

    def eissn
      return nil if attributes['issn-type'].blank?
      print_value = attributes['issn-type'].detect { |h| h['type'] == 'electronic' }
      return print_value['value'] if print_value
    end

    def isbn
      return nil if attributes['isbn-type'].blank?
      print_value = attributes['isbn-type'].detect { |h| h['type'] == 'print' } || attributes['isbn-type'].detect { |h| h['type'] == 'electronic' }
      return print_value['value'] if print_value['value']
      attributes['isbn-type'].first['value']
    end

    def doi
      attributes['DOI']
    end

    def volume
      attributes['volume']
    end

    def pagination
      attributes['page']
    end

    def issue
      attributes['issue']
    end

    def journal_title
      attributes['container-title'].first if attributes['container-title'].present?
    end

    def keyword
      attributes['subject']
    end

    def publisher
      attributes['publisher']
    end

    def official_url
      attributes['URL']
    end

    def funder
      if attributes.dig('funder').present?
        # attributes.dig('fundingReferences').first["funderName"]
        attributes["funder"].each_with_index.map do |hash_funder, index|
          {
            "funder_name" => hash_funder["name"], 'funder_doi' => hash_funder["DOI"],
            'funder_award' => hash_funder["award"], 'funder_position' => index }
        end
      end
    end

    def creator
      creator_group = attributes.dig('author') || attributes.dig('editor')
      if creator_group.present?
        extract_creators(creator_group)
      end
    end

    def extract_creators(creator_data)
      new_creator_group = []
      creator_data.each_with_index do |hash, index|
        if (hash.keys & ['given', 'family', 'ORCID']).any?
          record = creator_with_seperated_names(hash, index)
        else
          record = creator_without_seperated_names(hash, index)
        end
        new_creator_group << record
      end
      new_creator_group
    end

    def creator_with_seperated_names(hash, index)
        {
          creator_orcid: hash.try(:fetch, 'ORCID', '').split('/').last,
          creator_given_name:  hash["given"],
          creator_family_name: hash["family"],
          creator_name_type: 'Personal',
          creator_position: index
        }
    end

    def creator_without_seperated_names(hash, index)
       {
          creator_organization_name: hash["name"],
          creator_name_type: 'Organisational',
          creator_position: index
        }
    end

    def fetch_url_from_response
      vor_version_license = attributes['license'].detect { |h| h['content-version'] == 'vor' }
      return vor_version_license['URL'] if vor_version_license.present?
      max_time_stamp_license = attributes['license'].max_by { |h| h.try(:fetch, 'date-parts', '')['time-stamp'].to_f }
      return max_time_stamp_license['URL']  if max_time_stamp_license.present?
      attributes['license'].first['URL']
    end

    def data
      if error.present?
        { 'error' => error }
      else
        {
          title: title, published_year: date_published_year ,

          published_month: date_published_month, published_day: date_published_day,
          issn: issn, eissn: eissn, journal_title: journal_title,
          abstract: abstract, version: version, isbn: isbn,
          creator_group: creator, doi: doi, keyword: keyword, license: license,
          publisher: publisher, volume: volume, pagination: pagination, issue: issue,
          official_url: official_url

        }
       end
    end

  end
end
