module Ubiquity
  module BrowserDetectionHelper

    def client_browser_name(request)
     user_agent = request.env['HTTP_USER_AGENT'].downcase
     if user_agent =~ /msie/i
       render_browser_specific_files('Internet Explorer')
      else
       render_browser_specific_files('other')
     end
    end

   private

   def render_browser_specific_files(browser_name)
      if browser_name == "Internet Explorer"
        # this is a partial for ie
        render 'bl_partners_home_ie11'
      else
        # this is a partial
        render 'bl_partners_home.html'
      end
    end
  end
end
