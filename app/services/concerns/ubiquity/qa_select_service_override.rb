module Ubiquity
  module QaSelectServiceOverride

    def initialize(authority_name, custom_list = [])
      @authority = Qa::Authorities::Local.subauthority_for(authority_name)
      @custom_list = custom_list
    end

    def selective_dropdown_display
      selectable_options = select_active_options.map(&:first)

      if @custom_list.blank?
        selectable_options
      else
        selectable_options & @custom_list
      end

    end
  end
end
