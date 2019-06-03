module Hyrax
  # Mailer for contacting the administrator
  class ContactMailer < HykuMailer #ActionMailer::Base
    def contact(contact_form)
      @contact_form = contact_form
       account = Account.find_by(tenant: Apartment::Tenant.current)

      # Check for spam
      return if @contact_form.spam?
      headers = @contact_form.headers.dup
      headers[:subject] << " [#{host_for_tenant}]"
      headers[:to] = account.contact_email || Hyrax.config.contact_email
      if headers[:to] != Hyrax.config.contact_email
        headers[:bcc] = Hyrax.config.contact_email
      end
      mail(headers)

    end
  end
end
