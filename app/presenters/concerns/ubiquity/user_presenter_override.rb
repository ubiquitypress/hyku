#original file at https://github.com/samvera/hyrax/blob/v2.0.2/app/presenters/hyrax/dashboard/user_presenter.rb
module Ubiquity
  module UserPresenterOverride

    def render_recent_notifications
      if notifications.empty?
        t('hyrax.dashboard.no_notifications')
      else
        #render "hyrax/notifications/notifications", messages: notifications_for_dashboard
        render "shared/ubiquity/notifications/notifications", messages: notifications_for_dashboard
      end
    end

  end
end
