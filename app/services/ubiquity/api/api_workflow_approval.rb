module Ubiquity
  module Api
    class ApiWorkflowApproval
      attr_accessor :account, :work, :user, :approval_action, :comment, :ability

      def initialize(ability:, account:, work:, user:, approval_action: nil, comment: nil)
        @account = account
        @user = user
        @work = work
        @ability = ability
        @comment = comment
        @approval_action = approval_action
      end

      def is_valid_for_saving?
        valid_action = ['approve', "pending_review", "changes_required", 'comment_only', 'request_changes', 'request_review']
        is_valid_action = valid_action.include?(approval_action)
        new_work = work.class != ActiveSupport::HashWithIndifferentAccess ? work : SolrDocument.new(work)
        is_valid_user = approval_action.present? && (user.can?(:review, :submissions) || user.can?(:edit, new_work))
        if is_valid_action &&  is_valid_user
          true
        else
          false
        end
      end

      def sipity_entity
        # AccountElevator.switch!(account.cname)
        #work is ActiveSupport::HashWithIndifferentAccess when fetching a work via the api in views/api/v1/work/_work.json.jbuuldr,
        # we call these method to render comments for work under review

        if work.present? && work.class == ActiveSupport::HashWithIndifferentAccess
          work_class = work["has_model_ssim"].try(:first).try(:constantize)
          @sipity_entity ||= Sipity::Entity.find_by(proxy_for_global_id:  "gid://hyku/#{work_class}/#{work['id']}")
        elsif work.present?
          @sipity_entity ||= Sipity::Entity.find_by(proxy_for_global_id:  "gid://hyku/#{work.class}/#{work.id}")
        end
      end

      #returns records from the model Sipity::Comment
      def comments_on_work_for_review
        # AccountElevator.switch!(account.cname)
        if sipity_entity.present?
          sipity_entity.comments.map {|sipity_comment|
            {comment: sipity_comment.comment, updated_at: sipity_comment.updated_at, email: sipity_comment.name_of_commentor }
        }
        end
      end

      def workflow_state_name
        if sipity_entity.present?
          sipity_entity.workflow_state_name
        end
      end

      # def hyrax_workflow_action_form_object
      #   AccountElevator.switch!(account.cname)
      #   if @approval_action.present? && (['approve', 'request_changes'].exclude? approval_action)  && ability.can?(:edit, work)
      #     Hyrax::Forms::WorkflowActionForm.new(current_ability: ability, work: work , attributes: {name: approval_action, comment: comment})
      #   elsif @approval_action.present? && ability.can?(:review, :submissions)
      #     Hyrax::Forms::WorkflowActionForm.new(current_ability: ability, work: work , attributes: {name: approval_action, comment: comment})
      #   end
      # end

    #this leverages the following
    #https://github.com/samvera/hyrax/blob/v2.0.2/app/services/hyrax/workflow/permission_query.rb
    #https://github.com/samvera/hyrax/blob/v2.0.2/app/services/hyrax/workflow/workflow_action_service.rb
    #https://github.com/samvera/hyrax/blob/v2.0.2/app/forms/hyrax/forms/workflow_action_form.rb
    #the save below is used insteac of
      #Hyrax::Forms::WorkflowActionForm.new(current_ability: ability, work: work , attributes: {name: approval_action, comment: comment}).save
    #
      def save
        subject = Hyrax::WorkflowActionInfo.new(work, user)
        sipity_workflow_action = PowerConverter.convert_to_sipity_action(approval_action, scope: subject.entity.workflow)
        if approval_action.present?
          Hyrax::Workflow::WorkflowActionService.run(subject: subject, action: sipity_workflow_action, comment: comment)
        end
      end
    end
  end
end
