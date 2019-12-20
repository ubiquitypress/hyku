module Ubiquity
  module WorksControllerBehaviorOverride
    include ActiveSupport::Concern


    private

    def build_form
      curation_concern.account_cname = current_account.cname
      @form = work_form_service.build(curation_concern, current_ability, self)
    end

  end
end
