
Qa::Authorities::WebServiceBase.module_eval do

  def json(url)
    Rails.logger.info "Retrieving json for url: #{url}"
    #r = response(url).body
    #JSON.parse(r)
    r = response(url)
    r.parsed_response
  end

  def response(url)
    #Faraday.get(url) { |req| req.headers['Accept'] = 'application/json'}
    HTTParty.get(url)
  end
end


module Ubiquity
  module  CrossrefGenericAuthorityOverride
    extend ActiveSupport::Concern

    def build_query_url(q)
      query = ERB::Util.url_encode(untaint(q))
      "http://api.crossref.org/#{subauthority}?query=#{query}&mailto=tech@ubiquitypress.com"
    end

  end
end
