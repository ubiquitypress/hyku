module Hyrax
  class CreateNoteOnWorkService < AbstractMessageService
    attr_reader :note_text, :model, :work_id, :user
    def initialize(current_user, note_text, model, work_id)
      @user = current_user
      @note_text = note_text
      @model = model
      @work_id = work_id
    end

    # see `split_note_from_work` view helper method if changing the message_body
    def message_body
      '(<a href="/concern/' + @model.underscore + 's/' + @work_id + '">' + @work_id + '</a>) ' + @note_text
    end

    def subject
      I18n.t("hyrax.works.form.note.subject")
    end

    def depositor
      depositor_email = ActiveFedora::Base.find(@work_id).depositor
      depositor = ::User.where(email: depositor_email)
      # avoid returning an ActiveRecord::Relation object:
      depositor.first
    end

    def recipients
      [@user, depositor]
    end

    def call
      @user.send_message(recipients, message_body, subject)
    end
  end
end