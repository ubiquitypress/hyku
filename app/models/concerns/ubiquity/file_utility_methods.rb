module Ubiquity

  module FileUtilityMethods
    extend ActiveSupport::Concern

    included do
      after_save :add_file_avalaibility, on: :update
      before_destroy :remove_file_availability
    end

    private
#This method adds the file available after save to allow for faceting
    def add_file_avalaibility
      if self.parent.present?
        work = self.parent
        work.save
      end
    end

    def remove_file_availability
      if self.parent.present?
        work = self.parent
        work.file_availability = []
        work.save
      end
    end

  end
end
