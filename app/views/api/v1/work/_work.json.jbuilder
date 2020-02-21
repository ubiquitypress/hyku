#/home/edward/dev-2/hyku/app/views/api/v1/work/_work.json.jbuilder
if work["workflow_state_name_ssim"].try(:first) == "pending_review" && current_api_ability.present? && (current_api_ability.can?(:review, :submissions) )
  json.partial! 'api/v1/work/work_content', work: work

elsif work["workflow_state_name_ssim"].try(:first) == "pending_review" #&& !current_api_ability  #(current_api_ability.cannot?(:review, :submissions) )
  json.uuid    work['id']
  json.type 'work'
  json.related_url    work['related_url_tesim']
  json.work_type    work['has_model_ssim'].try(:first)
  json.title    work['title_tesim'].try(:first)
  json.alternative_title    work['alt_title_tesim']
  json.visibility    work['visibility_ssi']
  json.workflow_status  work["workflow_state_name_ssim"].try(:first)
  json.display   'partial'
elsif work["workflow_state_name_ssim"].try(:first) != ["pending_review"]
  json.partial! 'api/v1/work/work_content', work: work
end
