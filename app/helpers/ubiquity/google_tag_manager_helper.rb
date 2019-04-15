module Ubiquity
  module GoogleTagManagerHelper

    def render_gtm_head(host)
      tenant_gtm_id = get_tenant_name_from_url(host)
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
      tenant_gtm_id = get_tenant_name_from_url(host)
      return '' if tenant_gtm_id.blank?

      <<-HTML.strip_heredoc.html_safe
       <!-- Google Tag Manager (noscript) -->

      <noscript><iframe src='https://www.googletagmanager.com/ns.html?id="#{tenant_gtm_id}"'
                    height="0" width="0" style="display:none;visibility:hidden"></iframe></noscript>

      <!-- End Google Tag Manager (noscript) -->
      HTML
    end

    private

    def get_tenant_name_from_url(host)
      #defined IN Application_Helper.rb
      tenant_name = ubiquity_url_parser(host)
      if tenant_name.present?
        get_google_tag_manager_id(tenant_name)
      end
    end

    def get_google_tag_manager_id(key)
      #defined IN Application_Helper.rb
      tenant_hash = parse_tenant_settings_json(key)
      #note &. is ruby's safe navigator similar to rails try method
      #if tenant_hash is nil instead of a hash, it will return nil instead of noMethodError
      #
      tenant_hash&.dig("GTM_ID")
    end

  end
end
