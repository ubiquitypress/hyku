# Overriding the oai config to display the request url in the OAI template
# Overriding the oai_config method
# projectblacklight/blacklight_oai_provider/blob/master/app/controllers/concerns/blacklight_oai_provider/controller.rb#L29
module Ubiquity
  module OaiExtension
    extend ActiveSupport::Concern
    def oai_config
      blacklight_config.oai.merge(provider: { repository_url: request.original_url }) || {provider: { repository_url: request.original_url }}
    end
  end
end
