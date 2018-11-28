module Ubiquity
  class FileEmbargoActor < Hyrax::Actors::EmbargoActor
    #unlike in Hyrax::Actors::EmbargoActor , the work here is a file_set that belongs to a work
    def destroy
      puts "work inspect #{work.inspect}"
      file_set = work
      file_set.embargo_visibility! # If the embargo has lapsed, update the current visibility.
      file_set.deactivate_embargo!
      file_set.save!
      #parent is the work that this file is attached to
      file_set.parent.save!
    end
  end

end
