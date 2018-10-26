module Hyrax
  class SharedBehaviorsController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include Ubiquity::BreadcrumbOverride
    include Hyku::IIIFManifest

    private

      def after_update_response
        notes_on_work
        download_stats = WorkDownloadStat.find_by(work_uid: presenter.solr_document.id)
        download_stats.update_attributes(title: presenter.solr_document.title.first) if download_stats
        super
      end

      def after_create_response
        notes_on_work
        super
      end

      def notes_on_work
        model = presenter.solr_document[:has_model_ssim].first
        work_id = presenter.solr_document.id
        note = params.fetch(model.underscore.to_sym)['note']
        # TO DO : add link to work in note
        msg_subject = t("hyrax.works.form.note.subject")
        depositor_email = presenter.solr_document[:depositor_tesim].first
        work_depositor = ::User.where(email: depositor_email)
        current_user.send_message(work_depositor, note, msg_subject)
        new_conversation_subject(model, work_id)
      end

      # change Mailboxer::Conversation subject to store the Work a 'Note' is about
      def new_conversation_subject(model, work_id)
        c_subject = model + '_' + work_id
        conversation = Mailboxer::Conversation.last # should / could this be `find.('some_conversation_id')`
        conversation.subject = c_subject
        conversation.save
      end

  end
end
