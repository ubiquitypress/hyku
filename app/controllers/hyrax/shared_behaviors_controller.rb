module Hyrax
  class SharedBehaviorsController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks

    include Hyku::IIIFManifest

    # override method from hyrax/app/controllers/concerns/hyrax/breadcrumbs.rb
    # so we don't display `add_breadcrumb_for_action` when a user is not signed_in
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

      private

      def after_update_response
        download_stats = WorkDownloadStat.find_by(work_uid: presenter.solr_document.id)
        download_stats.update_attributes(title: presenter.solr_document.title.first) if download_stats
        super
      end
  end
end
