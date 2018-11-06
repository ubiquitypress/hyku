UserMailbox.class_eval do

  def destroy(message_id)
    msg = Mailboxer::Conversation.find(message_id)
    return "You do not have privileges to delete the notification..." unless msg.participants.include? user
    if work_note?(msg)
      msg.move_to_trash(user)
      return nil
    end
    delete_message(msg)
    empty_trash(msg.participants[0])
    nil
  end

  private

    # `subject` of Mailboxer::Conversation starts with the model name for the 'Notes' tab on Works forms
    # see SharedBehaviorsController #`new_conversation_subject`
    def work_note?(msg)
      models = ["Article", "Book", "BookContribution", "ConferenceItem", "Dataset", "Image", "Report", "GenericWork"]
      models.include?(msg.subject.split('_').first)
    end

end
