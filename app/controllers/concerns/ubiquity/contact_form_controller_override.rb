# Defined in https://github.com/samvera/hyrax/blob/v2.0.2/app/forms/hyrax/forms/batch_edit_form.rb
module Ubiquity

  module ContactFormControllerOverride
    include ActiveSupport::Concern

    def create
    # not spam and a valid form
      if @contact_form.valid?
        Hyrax::ContactMailer.contact(@contact_form).deliver_now unless params["bot_catch"].present?
        flash.now[:notice] = 'Thank you for your message!'
        after_deliver unless params["bot_catch"].present?
        @contact_form = Hyrax::ContactForm.new
      else
        flash.now[:error] = 'Sorry, this message was not sent successfully. '
        flash.now[:error] << @contact_form.errors.full_messages.map(&:to_s).join(", ")
      end
      render :new
      rescue RuntimeError => exception
      handle_create_exception(exception)
    end

 end
end
