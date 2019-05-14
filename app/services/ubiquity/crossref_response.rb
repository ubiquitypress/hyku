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
      attributes['published-online']['date-parts'].first[0] if attributes['published-online'].present?
    end

    def date_published_month
      attributes['published-online']['date-parts'].first[1] if attributes['published-online'].present?
    end

    def license
      return nil if attributes['license'].blank?
      url_array = fetch_url_from_response.split('/')
      url_collection = Hyrax::LicenseService.new.select_active_options.map(&:last)
      regex_url = %r{(?:http|https):\/\/(?:www.|)(#{url_array[-4]})\/(#{url_array[-3]})\/(#{url_array[-2]})\/(#{url_array[-1]})}
      url_collection.select { |e| e =~ regex_url }.first
    end


    def date_published_day
      attributes['published-online']['date-parts'].first[2] if attributes['published-online'].present?
    end

    def issn
      attributes['ISSN'].first if attributes['ISSN'].present?
    end

    def eissn
      attributes['issn-type'].first['value'] if attributes['issn-type'].present?
    end

    def isbn
      return nil if attributes['isbn-type'].blank?
      print_value = attributes['isbn-type'].detect { |h| h['type'] == 'print' || h['type'] == 'electronic' }
      return print_value['value'] if print_value['value']
      attributes['isbn-type'].first['value']
    end

    def doi
      attributes['DOI']
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

    def auto_populated_fields
      fields = []
      fields << 'Title' if title.present?
      fields << 'Creator' if creator.present?
      fields << "Published year" if date_published_year.present?
      fields << "Published month" if date_published_month.present?
      fields << "Published day" if date_published_day.present?
      fields << 'DOI' if doi.present?
      fields << 'Journal Title' if journal_title.present?
      fields << 'ISSN' if issn.present?
      fields << 'eISSN' if eissn.present?
      fields << 'Abstract' if abstract.present?
      fields << 'Keyword' if keyword.present?
      fields << 'ISBN' if isbn.present?
      fields << 'Licence' if license.present?
      fields << 'Publisher' if publisher.present?
      # fields << 'version' if version.present?

      "The following fields were auto-populated - #{fields.to_sentence}"
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
          auto_populated: auto_populated_fields, publisher: publisher
        }
      end
    end
  end
end
