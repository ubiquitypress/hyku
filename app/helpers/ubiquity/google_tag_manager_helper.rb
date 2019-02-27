module Ubiquity
  module GoogleTagManagerHelper

   def render_gtm_head(host)

     tenant_gtm_id =  get_tenant_name_from_url(host)
     puts "mumiiii #{tenant_gtm_id}"
     return '' if tenant_gtm_id.blank?

    <<-HTML.strip_heredoc.html_safe
      <!-- Google Tag Manager -->
    <script>
    (function(w,d,s,l,i){w[l]=w[l]||[];w[l].push({'gtm.start':
            new Date().getTime(),event:'gtm.js'});var f=d.getElementsByTagName(s)[0],
        j=d.createElement(s),dl=l!='dataLayer'?'&l='+l:'';j.async=true;j.src=
        'https://www.googletagmanager.com/gtm.js?id='+i+dl;f.parentNode.insertBefore(j,f);
    })(window,document,'script','dataLayer', "#{tenant_gtm_id}");
  </script>
  <!-- End Google Tag Manager -->
    HTML
  end

  def render_gtm_body(host)
    #render 'layouts/google/gtm_body'
    tenant_gtm_id =  get_tenant_name_from_url(host)
    return '' if tenant_gtm_id.blank?

    <<-HTML.strip_heredoc.html_safe
     <!-- Google Tag Manager (noscript) -->

    <noscript><iframe src='https://www.googletagmanager.com/ns.html?id="#{tenant_gtm_id}"'
                    height="0" width="0" style="display:none;visibility:hidden"></iframe></noscript>

   <!-- End Google Tag Manager (noscript) -->
    HTML
  end

   private

    def ubiquity_url_parser(host)
      full_url = URI.parse(host)
      full_url.host.split('.').first
    end

    def get_tenant_name_from_url(host)
      tenant_name  = ubiquity_url_parser(host)
      tenant_name = 'bl'  if tenant_name == tenants_hash(tenant_name)
      Rails.application.config.google_tag_manager_id[tenant_name.to_sym]
    end

    def tenants_hash(tenant)
      hash_map = {
        'sandbox' => 'sandbox',
        "bl-demo" => "bl-demo",
        "mola-demo" => "mola-demo",
        "tate-demo" => "tate-demo",
        "britishmuseum-demo" => "britishmuseum-demo",
        "nms-demo" => "nms-demo"
      }
      hash_map[tenant]
    end
  end
end
