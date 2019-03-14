#overriding methods from https://github.com/samvera/hyrax/blob/master/app/controllers/concerns/hyrax/breadcrumbs.rb

module Ubiquity
  module BreadcrumbOverride
    include Hyrax::BreadcrumbsForWorks

    def default_trail
      #add_breadcrumb I18n.t('hyrax.controls.home'), hyrax.root_path
      add_breadcrumb I18n.t('hyrax.dashboard.title'), hyrax.dashboard_path if user_signed_in?
    end

    # Don't display `add_breadcrumb_for_action` when a user is not signed_in
    def trail_from_referer
      case request.referer
      when /catalog/
        #add_breadcrumb I18n.t('hyrax.controls.home'), hyrax.root_path
        add_breadcrumb I18n.t('hyrax.bread_crumb.search_results'), request.referer
      when //
        add_breadcrumb I18n.t('hyrax.bread_crumb.search_results'), request.referer
      else
        default_trail
        add_breadcrumb_for_controller if user_signed_in?
        add_breadcrumb_for_action if user_signed_in?
      end
    end

  end
end
