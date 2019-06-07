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
      rurl_array.pop if url_array.last == 'legalcode'
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
      attributes['ISSN'].first if attributes['ISSN'].present?
    end

    def eissn
      return nil if attributes['issn-type'].blank?
      print_value = attributes['issn-type'].detect { |h| h['type'] == 'electronic' } || attributes['issn-type'].detect { |h| h['type'] == 'print' }
      return print_value['value'] if print_value['value']
      attributes['issn-type'].first['value']
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

    def creator
      creator_group = attributes.dig('author') || attributes.dig('editor')
      if creator_group.present?
        if creator_group.first.keys && ['given', 'family', 'ORCID'].any?
          creator_with_seperated_names(creator_group)
        else
          creator_without_seperated_names(creator_group)
        end
      end
    end

    def keyword
      attributes['subject']
    end

    def publisher
      attributes['publisher']
    end


    def creator_with_seperated_names(data)
      new_creator_group = []
      data.each_with_index do |hash, index|
        hash = {
          creator_orcid: hash.try(:fetch, 'ORCID', '').split('/').last,
          creator_given_name:  hash["given"],
          creator_family_name: hash["family"],
          creator_name_type: 'Personal',
          creator_position: index
        }
        new_creator_group << hash
      end
      new_creator_group
    end

    url = def fetch_url_from_response
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
          title: title, published_year: date_published_year,
          published_month: date_published_month, published_day: date_published_day,
          issn: issn, eissn: eissn, journal_title: journal_title,
          abstract: abstract, version: version, isbn: isbn,
          creator_group: creator, doi: doi, keyword: keyword, license: license,
          publisher: publisher, volume: volume, pagination: pagination, issue: issue
        }
      end
    end
  end
end
