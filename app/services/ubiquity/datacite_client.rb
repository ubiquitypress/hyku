module Ubiquity
  class DataciteClient
    include HTTParty
    base_uri 'https://api.datacite.org'
    default_timeout 6

    attr_accessor :path

    def initialize(url)
      #@path = path
      #sets the value of the path ,ethod
      parse_url(url)
    end

    def fetch_record
      #result = self.class.get("/works/#{path}")
      result = self.class.get("#{path}")
      response_object(result)
    end

    private

    def response_object(result)
      response_hash = result.parsed_response
      Ubiquity::DataciteResponse.new(response_hash)
    end

    def parse_url(url)
      uri = URI.parse(url)
      if (uri.scheme.present? &&  uri.host.present?)
        path_name = uri.path
        use_path(path_name)
      elsif (uri.scheme.present? == false && uri.host.present? == false && uri.path.present?)
        use_path(uri.path)
      end
    end

    def use_path(path_name)
      puts "uri #{path_name}"
      split_path = path_name.split('/').reject(&:empty?)
      if split_path.length == 3 && split_path.first == 'works'
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
      elsif split_path.length == 2 && (not split_path.include? 'works')
        path_name = path_name.prepend('/') if path_name.slice(0) != "/"
        @path = "/works/#{path_name}"
      end
    end

  end
end
