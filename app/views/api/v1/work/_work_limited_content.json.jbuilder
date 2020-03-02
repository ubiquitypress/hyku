json.admin_set_name work[ "admin_set_tesim"].try(:first)
json.uuid    work['id']
json.type 'work'
json.related_url    work['related_url_tesim']
json.work_type    work['has_model_ssim'].try(:first)
json.title    work['title_tesim'].try(:first)
json.alternative_title    work['alt_title_tesim']
json.visibility    work['visibility_ssi']
json.workflow_status  work["workflow_state_name_ssim"].try(:first)
json.display   'partial'
