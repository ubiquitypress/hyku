
module Ubiquity
  class ApiWorkflowApproval
    attr_accessor :account, :work, :user, :approval_action, :comment, :ability
    def initialize(ability:, account:, work:, user:, approval_action:, comment: )
      @account = account
      @work = work
      @ability = ability
      @comment = comment
      @approval_action = approval_action
    end

    def sipity_entity
       AccountElevator.switch!(account.cname)
       @sipity_entity ||= Sipity::Entity.find_by(proxy_for_global_id:  "gid://hyku/#{work.class}/#{work.id}")
    end

    #returns records from the model Sipity::Comment
    def comments_on_work_for_review
      AccountElevator.switch!(account.cname)
      if sipity_entity.present?
        sipity_entity.comments.map {|sipity_comment| {comment: sipity_comment.comment, updated_at: sipity_comment.updated_at} }
      end
    end

    def workflow_state_name
      if sipity_entity
        sipity_entity.workflow_state_name
      end
    end

    def hyrax_workflow_action_form_object
      AccountElevator.switch!(account.cname)
      Hyrax::Forms::WorkflowActionForm.new(current_ability: ability, work: work , attributes: {name: approval_action, comment: comment})
    end

  end
end
