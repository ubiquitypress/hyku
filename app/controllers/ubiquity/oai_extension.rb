module Ubiquity
  module OaiExtension
    extend ActiveSupport::Concern
    def oai_config
      blacklight_config.oai.merge(provider: { repository_url: request.original_url })
    end
  end
end
