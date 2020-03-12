# example of usage
#user = User.find_by(email: 'test-manager@example.com')
#notifications = user.mailbox.inbox
#p = Ubiquity::Api::RedirectWorkIdInWorkflowNotification.new(message: notifications.first, url: 'http://university-demo.localhost:8080/dashboard/my/collections?locale=en')
#p.point_link_to_frontend
#

module Ubiquity
  module Api
    class RedirectWorkIdInWorkflowNotification

      attr_accessor :user, :url, :message

      def initialize(user: nil, url: nil , message:  nil)
        @user = user
        @url = url
        @message = message
      end

     #duplicated from https://github.com/samvera/hyrax/blob/v2.0.2/app/presenters/hyrax/dashboard/user_presenter.rb
     #because that class has many methods we dont need and also requires arguments like view_context, since
     #which we dont need
      def notifications
        if user.present?
         user.mailbox.inbox
        end
      end

      def swap_backend_link_to_frontend_link
        return nil unless notifications_for_dashboard.present?

        notifications_for_dashboard.map do |notification|
          notification_message = get_original_text(notification)
          if notification_message.present?
            extracted_link_text = extract_link_from_brackets(notification_message)
            new_link = regenerate_link(notification_message)
            replace_with_frontend_link = notification_message.gsub(extracted_link_text, new_link)
          end
        end.compact
      end

      def point_link_to_frontend
        notification_message = get_original_text(message)
        if notification_message.present?
          extracted_link_text = extract_link_from_brackets(notification_message)
          new_link = regenerate_link(notification_message)
          replace_with_frontend_link = notification_message.gsub(extracted_link_text, new_link)
        end
      end

      def get_original_text(message_object)
        if message_object.present?
          message_object.last_message.body.html_safe
        end
      end

      def extract_link_from_brackets(text)
        if text.present?
         text[/\(.*?\)/]
        end
      end

      def extract_id_from_text(text)
        if text.present?
          text.match(/>(.*)</)[1]
        end
      end

      def regenerate_link(text)
        id = extract_id_from_text(text)
        get_url = new_url
        if id.present?
          "(<a href=#{get_url}/work/#{id}> #{id} </a>)"
        end
      end

      def new_url
        if url.present?
          Ubiquity::ParseTenantWorkSettings.new(url).redirect_url
        end
      end

      private

      def notifications_for_dashboard
        if notifications.present?
          notifications.limit(Hyrax.config.max_notifications_for_dashboard)
        end
      end

    end
  end
end
