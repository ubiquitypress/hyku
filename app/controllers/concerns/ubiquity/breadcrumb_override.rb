module Ubiquity
  module BreadcrumbOverride
    include Hyrax::BreadcrumbsForWorks

    # Don't display `add_breadcrumb_for_action` when a user is not signed_in
    def trail_from_referer
      case request.referer
      when /catalog/
        add_breadcrumb I18n.t('hyrax.controls.home'), hyrax.root_path
        add_breadcrumb I18n.t('hyrax.bread_crumb.search_results'), request.referer
      else
        default_trail
        add_breadcrumb_for_controller if user_signed_in?
        add_breadcrumb_for_action if user_signed_in?
      end
    end
  end
end