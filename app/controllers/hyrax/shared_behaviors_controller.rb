module Hyrax
  class SharedBehaviorsController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include Ubiquity::BreadcrumbOverride
    include Hyku::IIIFManifest

    private

      def after_update_response
        notes_on_work if params[hash_key_for_curation_concern]['note'].present?
        download_stats = WorkDownloadStat.find_by(work_uid: presenter.solr_document.id)
        download_stats.update_attributes(title: presenter.solr_document.title.first) if download_stats
        super
      end

      def after_create_response
        notes_on_new_work if params[hash_key_for_curation_concern]['note'].present?
        super
      end

      def notes_on_work
        model = presenter.model
        work_id = presenter.solr_document.id
        create_notes(model, work_id)
      end

      # works being ingested cannot access a presenter like in 'notes_on_work'
      def notes_on_new_work
        work_gid = Sipity::Entity.last.proxy_for_global_id
        arr = work_gid.split('hyku/').last
        model = arr.split('/').first
        work_id = arr.split('/').last
        create_notes(model, work_id)
      end

      # TO DO: make the notification link to the work in a service instead of inserting a href here?
      # see `split_note_from_work` view helper method if changing the note param passed to `send_message` below
      def create_notes(model, work_id)
        note = '(<a href="/concern/' + model.underscore + 's/' + work_id + '">' + work_id + '</a>) '
        note << params[hash_key_for_curation_concern]['note']
        msg_subject = t("hyrax.works.form.note.subject")
        depositor_email = ActiveFedora::Base.find(work_id).depositor
        work_depositor = ::User.where(email: depositor_email)
        current_user.send_message(work_depositor, note, msg_subject)
        new_conversation_subject(model, work_id)
      end

      # change Mailboxer::Conversation subject to store the Work a 'Note' is about
      def new_conversation_subject(model, work_id)
        c_subject = model + '_' + work_id
        conversation = Mailboxer::Conversation.last # TO DO `find.('some_conversation_id')`
        conversation.subject = c_subject
        conversation.save
      end

  end
end
