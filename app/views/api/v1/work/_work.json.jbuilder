#/home/edward/dev-2/hyku/app/views/api/v1/work/_work.json.jbuilder
review_data = Ubiquity::ApiWorkflowApproval.new(ability: current_ability, account: current_account, work: @work, user: current_user)

if (["pending_review", "changes_required"].include? work["workflow_state_name_ssim"].try(:first) )  && current_api_ability.present? && (current_api_ability.can?(:review, :submissions) )
  json.partial! 'api/v1/work/work_content', work: work
  json.review_data  review_data.comments_on_work_for_review
elsif (["pending_review", "changes_required"].include? work["workflow_state_name_ssim"].try(:first) ) && (current_user.try(:email) == work["depositor_tesim"].try(:first)) && (work["edit_access_person_ssim"].include? current_user.try(:email) )
  json.uuid    work['id']
  json.type 'work'
  json.related_url    work['related_url_tesim']
  json.work_type    work['has_model_ssim'].try(:first)
  json.title    work['title_tesim'].try(:first)
  json.alternative_title    work['alt_title_tesim']
  json.visibility    work['visibility_ssi']
  json.workflow_status  work["workflow_state_name_ssim"].try(:first)
  json.display   'partial'

  json.review_data  review_data.comments_on_work_for_review

elsif (["pending_review", "changes_required"].include? work["workflow_state_name_ssim"].try(:first) ) && (current_user.try(:email) == work["depositor_tesim"].try(:first))
  json.uuid    work['id']
  json.type 'work'
  json.related_url    work['related_url_tesim']
  json.work_type    work['has_model_ssim'].try(:first)
  json.title    work['title_tesim'].try(:first)
  json.alternative_title    work['alt_title_tesim']
  json.visibility    work['visibility_ssi']
  json.workflow_status  work["workflow_state_name_ssim"].try(:first)
  json.display   'partial'
  json.review_data  nil
elsif current_user.blank? && (["pending_review", "changes_required"].exclude?(work["workflow_state_name_ssim"].try(:first) ) )
  json.partial! 'api/v1/work/work_content', work: work
  json.review_data  nil
end
