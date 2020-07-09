module Ubiquity
  class  DataciteClient

    attr_accessor :path

    def initialize(url)
      #sets the value of the path ,method
      decoded_url = CGI.unescape(url)
      parse_url(decoded_url)
    end

    def fetch_record
      result = fetch_record_from_crossref
      if result.class == HTTParty::Response
        response_hash = result.parsed_response
        return response_object_from_crossref(response_hash) if response_hash.class == Hash && response_hash['message'].class == Hash
      end
      result = fetch_record_from_datacite
      if result.class == HTTParty::Response
        response_hash = result.parsed_response
        response_object_from_datacite(response_hash, result)
      else
        Ubiquity::DataciteResponse.new(error: error_message, result: result)
      end
    end

    def fetch_record_from_crossref
      handle_client do
        HTTParty.get("https://api.crossref.org/works/#{path}")
      end
    end

    def fetch_record_from_datacite
      handle_datacite_client do
        HTTParty.get("https://api.datacite.org/dois/#{path}")
      end
    end

    private

    def response_object_from_datacite(response_hash, result)
      if response_hash.present? && response_hash.class == Hash && response_hash['data'].class == Hash
        Ubiquity::DataciteResponse.new(response_hash: response_hash, result: result)
      else
        puts "Successful DataciteClient api call but HTTParty parsed_response returned a string instead of hash, so change url"
        Ubiquity::DataciteResponse.new(error: error_message, result: result)
      end
    end

    def response_object_from_crossref(response_hash)
      Ubiquity::CrossrefResponse.new(response_hash)
    end

    def parse_url(url)
      url = url.strip

      handle_client do
        uri = Addressable::URI.convert_path(url)
        if (uri.scheme.present? &&  uri.host.present?)
          path_name = uri.path
          use_path(path_name)
        elsif (uri.scheme.present? == false && uri.host.present? == false && uri.path.present?)
          use_path(uri.path)
        end
      end
    end

    def use_path(path_name)
      puts "uri #{path_name}"
      split_path = path_name.split('/').reject(&:empty?)
      if (split_path.length == 3 && split_path.first == 'works') || ( split_path.length == 4 && split_path.first == 'works')
        #changes "works/10.5438/0012" to "/works/10.5438/0012"
        path_name = path_name.prepend('/') if path_name.slice(0) != "/"
        @path = path_name
      elsif split_path.length == 4 && split_path.first == 'api.datacite.org'
        #data here is ["api.datacite.org", "works", "10.5438", "0012"]
        #shift removes the first element
        split_path.shift
        #we get back "works/#{path_name}"
        url_path =split_path.join('/')
        #we get back "/works/#{path_name}"
        new_url_path = url_path.prepend('/')
        @path = new_url_path

        #when split_path returns ["10.7488", "ds", "2109"]
        #we get the first two elements that is "10" with
        #split_path.first.slice(0..1)
      elsif (split_path.length == 2 && (not split_path.include? 'works')) || (split_path.length == 3 && split_path.first.slice(0..1) == '10')
        path_name = path_name.prepend('/') if path_name.slice(0) != "/"
        @path = path_name
      end
    end

    def handle_client
      begin
        yield
      rescue  URI::InvalidURIError, HTTParty::Error, Net::HTTPNotFound, NoMethodError, Net::OpenTimeout, StandardError => e
        puts "DataciteClient error #{e.inspect}"
      end
    end

    def handle_datacite_client
      begin
        yield
      rescue URI::InvalidURIError, HTTParty::Error, Net::HTTPNotFound, NoMethodError, Net::OpenTimeout, StandardError => e
        puts " This is from the datacitre client #{e.inspect}"
      end
    end

    def error_message
      "Sorry no data was fetched. Please ensure this is a valid DataCite DOI or URL eg 10.5438/0012 or https://doi.org/10.5438/0012 or
      http://dx.doi.org/10.18154/RWTH-CONV-020567 or http://api.crossref.org/works/10.11647/OBP.0172. If you are sure it is valid please refresh the page and try again."
    end

  end
end
