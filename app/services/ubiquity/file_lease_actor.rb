module Ubiquity
  class FileLeaseActor < Hyrax::Actors::LeaseActor
    #unlike in Hyrax::Actors::LeaseActor , the work here is a file_set that belongs to a work
    #work
    def destroy
      file_set = work
      file_set.lease_visibility! # If the lease has lapsed, update the current visibility.
      file_set.deactivate_lease!
      file_set.save!
      #this is the work that the file_set is attached to
      file_set.parent.save!
    end

  end

end
