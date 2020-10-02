#/home/edward/dev-2/hyku/app/views/api/v1/work/_work.json.jbuilder
review_data = Ubiquity::Api::ApiWorkflowApproval.new(ability: current_ability, account: current_account, work: @work, user: current_user)

if (["pending_review", "changes_required"].include? work["workflow_state_name_ssim"].try(:first) )  && current_api_ability.present? && (current_api_ability.can?(:review, :submissions) )
  json.partial! 'api/v1/work/work_content', work: work
  json.review_data  review_data.comments_on_work_for_review
elsif (["pending_review", "changes_required"].include? work["workflow_state_name_ssim"].try(:first) ) && (current_user.try(:email) == work["depositor_tesim"].try(:first)) && (work["edit_access_person_ssim"].include? current_user.try(:email) )
  json.partial! 'api/v1/work/work_limited_content', work: work
  json.review_data  review_data.comments_on_work_for_review

elsif (["pending_review", "changes_required"].include? work["workflow_state_name_ssim"].try(:first) ) 
  json.partial! 'api/v1/work/work_limited_content', work: work
  json.review_data  nil
else
  json.partial! 'api/v1/work/work_content', work: work
  json.review_data  nil
end
