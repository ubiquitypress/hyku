class UbiquityWorkExpiryJob < ActiveJob::Base
  queue_as :expiry_service
  # adds get_visibility_after_expiration and compare_visibility_after_expiration?
  include Ubiquity::ExpiryUtil
  def perform(work_id, tenant, work_type)
    AccountElevator.switch!("#{tenant}")
    if work_type == 'work'
      perform_work_expiry(work_id)
    else
      perform_file_expiry(work_id)
    end
  end

  private

    def perform_work_expiry(work_id)
      @work = ActiveFedora::Base.find(work_id)
      if @work
        if @work.under_embargo?
          auto_expire_embargo
        elsif @work.active_lease?
          auto_expire_lease
        end
        update_expired_file_sets
        unless @work.under_embargo? || @work.active_lease?
          WorkExpiryService.where(work_id: work_id).first.destroy
        end
      else
        WorkExpiryService.where(work_id: work_id).first.destroy
      end
    end

    def perform_file_expiry(work_id)
      file_set = ActiveFedora::Base.find(work_id)
      if file_set
        if file_set.under_embargo?
          auto_expire_file_embargo file_set
        elsif file_set.active_lease?
          auto_expire_file_lease file_set
        end
        unless file_set.under_embargo? ||file_set.active_lease?
          WorkExpiryService.where(work_id: work_id).first.destroy
        end
      else
        WorkExpiryService.where(work_id: work_id).first.destroy
      end
    end

    def auto_expire_embargo
      # compare_visibility_after_expiration?(work, 'embargo')
      puts "expiring work embargo #{@work}"
      if @work.embargo_release_date.present?
        puts "embargo work with date #{@work}"
        Hyrax::Actors::EmbargoActor.new(@work).destroy
      elsif compare_visibility_after_expiration?(@work, 'embargo')
        puts "work with no embargo date #{@work}"
        @work.visibility = get_visibility_after_expiration(@work, 'embargo')
        @work.save if @work.visibility.present?
      end
    end

    def auto_expire_lease
      puts "expiring work lease #{@work}"
      if @work.lease_expiration_date.present?
        puts "lease work with date #{@work}"
        Hyrax::Actors::LeaseActor.new(@work).destroy
      elsif compare_visibility_after_expiration?(@work, 'lease')
        puts "work with no lease date #{work}"
        @work.visibility = get_visibility_after_expiration(@work, 'lease')
        @work.save if @work.visibility.present?
      end
    end

    def update_expired_file_sets
      @work.file_sets.each do |file_set|
        if file_set.under_embargo?
          auto_expire_file_embargo file_set
        elsif file_set.active_lease?
          auto_expire_file_lease file_set
        end
      end
    end

    def auto_expire_file_embargo(file_set)
      puts "expiring fileset embargo #{file_set}"
      if file_set.embargo_release_date.present?
        puts "embargo file_set with date #{file_set}"
        Ubiquity::FileEmbargoActor.new(file_set).destroy
      elsif compare_visibility_after_expiration?(file_set, 'embargo')
        puts "file_set with no embargo date #{file_set}"
        file_set.visibility = get_visibility_after_expiration(file_set, 'embargo')
        file_set.save if file_set.visibility.present?
      end
    end

    def auto_expire_file_lease(file_set)
      puts "expiring fileset lease #{file_set}"
      if (file_set.lease_expiration_date.present?)
        puts "lease file_set with date #{file_set}"
        Ubiquity::FileLeaseActor.new(file_set).destroy
      elsif compare_visibility_after_expiration?(file_set, 'lease')
        puts "file_set with no lease date #{file_set}"
        file_set.visibility = get_visibility_after_expiration(file_set, 'lease')
        file_set.save if file_set.visibility.present?
      end
    end
end
