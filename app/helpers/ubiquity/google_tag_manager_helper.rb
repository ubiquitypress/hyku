module Ubiquity
  module GoogleTagManagerHelper

  def render_gtm_head
    render 'layouts/google/gtm'
  end

  def render_gtm_body
    render 'layouts/google/gtm_body'
  end

  def ubiquity_url_parser(host)
    full_url = URI.parse(host)
    full_url.host.split('.').first
  end

  end
end