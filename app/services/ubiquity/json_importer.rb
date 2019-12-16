#reverted ability to update via the importer
#https://github.com/ubiquitypress/hyku/pull/432
#this commit contains the code on this file which added the ability to update code via the importer
#https://github.com/ubiquitypress/hyku/pull/407
#https://trello.com/c/ny0pVK4C/584-v15924-allow-json-importer-to-update-records-based-on-keys-in-imported-csv-revert-before-release-to-live

#To run from rails console
#create a json or use the constants set as a examples in queue_import.#!/usr/bin/env ruby -wKU
# data = sample
#Ubiquity::JsonImporter.new(data).run
#
module Ubiquity
  class JsonImporter
    attr_reader :ubiquity_model_class
    #hash_for_import method is used to
    #determine what hash keys to use. For existing records using the attributes key and for new records use the keys from the imported json
    #
    #attributes_hash
    #this is where we temporarily store the parsed imported data before save

    attr_accessor :attributes_hash, :work, :hash_for_import

    def initialize(data)
      @attributes_hash = {}
      @data = data
      $stdout.puts "Log Json data loaded #{@data}"
      @collection_id = data.delete('collection_id') || data.delete(:collection_id)
      @data_id  = data.delete('id') || data.delete(:id)
      @tenant = data['tenant'] || data[:tenant]
      @domain = data['domain'] || data[:domain]
      @tenant_domain = @tenant + '.' + @domain
      @data_hash = HashWithIndifferentAccess.new(data)
      $stdout.puts "@data_hash values #{@data_hash.inspect}"
      @file = @data_hash[:file] || @data_hash['file'] || @data_hash[:files] || @data_hash['files']
      @ubiquity_model_class = @data_hash.with_indifferent_access["type"].try(:constantize) || model_instance.class
      @work_instance = model_instance
    end

    def run
      AccountElevator.switch!("#{@tenant_domain}")
      email = Hyrax.config.batch_user_key
      @user = User.where(email: @work_instance.depositor).first ||  User.find_or_create_by(email: email) { |user|  user.password = 'abcdefgh'; user.password_confirmation = 'abcdefgh'}
      @attributes_hash['depositor'] = @user.email unless @work_instance.depositor
      $stdout.puts "Started parsing the json data"

      hash_from_work_and_submitted_data.each_with_index do |(key, val), index|
        #index needed to to ensure set_default_work_visibility is called once inside populate_array_field
        ##populate_array_field(key, val, index)
        ##populate_json_field(key, val)
        ##populate_single_fields(key, val)
        Ubiquity::JsonImport::FieldsPopulator.new(@work_instance,@data_hash, @attributes_hash, key, val, index).populate_array_field
        Ubiquity::JsonImport::FieldsPopulator.new(@work_instance,@data_hash, @attributes_hash, key, val, index).populate_json_field
        Ubiquity::JsonImport::FieldsPopulator.new(@work_instance,@data_hash, @attributes_hash, key, val, index).populate_single_fields


      end
      @attributes_hash['account_cname'] = @tenant_domain
      @attributes_hash['date_modified'] = Hyrax::TimeService.time_in_utc
      @attributes_hash['date_uploaded'] = Hyrax::TimeService.time_in_utc unless @work_instance.date_uploaded.present?
      set_default_work_visibility(@data_hash[:visibility])
      set_admin_set(@data_hash[:admin_set_id])
      #save the work
      create_or_update_work
      add_state_to_work
      $stdout.puts "work was successfully created"

      attach_files
      add_work_to_collection

      @work_instance
      @work = @work_instance
      self
    end

    private

    def add_work_to_collection
      if @collection.present? && @work_instance.class != Collection
        collection = ActiveFedora::Base.find(@collection_id)
        collection.add_member_objects([@work_instance.id])
        collection.save
      end
      rescue ActiveFedora::ObjectNotFoundError
        $stdout.puts "collection with id #{@collection_id} does not exist"
    end

    #determine what hash keys to use. For existing records using the attributes key and for new records use the keys from the imported json
    #
    def hash_from_work_and_submitted_data
      work_keys = @work_instance.attributes.keys
      work_hash_with_indifference_access = @work_instance.attributes.with_indifferent_access
      data_with_indifferent_access = @data.with_indifferent_access
      if @work_instance.new_record?
         @hash_for_import = data_with_indifferent_access.slice(*work_keys)
      else
        @hash_for_import = work_hash_with_indifference_access.slice(*@data.keys)
      end

    end

    def create_or_update_work
      if @work_instance.new_record?
        @work_instance.attributes = attributes_hash
        $stdout.puts "creating a new-work #{@work_instance.inspect}"
        @work_instance.save!
      else
        $stdout.puts "updating-work with #{attributes_hash.inspect}"
        @work_instance.update(attributes_hash)
      end
    end

    def model_instance
      AccountElevator.switch!("#{@tenant_domain}")
      work = ActiveFedora::Base.find(@data_id)
      if work.present?
        work
      else
        new_work
      end

      rescue ActiveFedora::ObjectNotFoundError
        new_work
    end

    def new_work
      return ubiquity_model_class.new(id: @data_id)  if @data_id.present?
      ubiquity_model_class.new
    end

    def add_state_to_work
      work = @work_instance
      state = Sipity::WorkflowState.where(name: "deposited").first
      sipity_entity = Sipity::Entity.where(proxy_for_global_id: work.to_global_id.to_s).first

      if state.present? && (not sipity_entity.present?)
        Sipity::Entity.create!(proxy_for_global_id: work.to_global_id.to_s, workflow_state: state, workflow: state.workflow)
      end
    end

    def set_default_work_visibility(value)
      if ['open', 'restricted'].include?(value)
        puts "setting visibility from hash - #{value.inspect}"
        @work_instance.visibility = value
      else
         $stdout.puts "setting visibility to private in json importer - #{value.inspect}"
         @work_instance.visibility = (Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE) unless @work_instance.visibility.present?
      end
    end

    def set_admin_set(value)
      if value.present? && @work_instance.class != Collection
        $stdout.puts "setting admin_set to - #{value.inspect}"
        @attributes_hash['admin_set_id'] = value
      elsif @work_instance.class != Collection
         $stdout.puts "setting adminset to admin_set/default "
         @attributes_hash['admin_set_id'] = "admin_set/default" unless @work_instance.admin_set_id.present?
      end
    end

    def attach_files
      Ubiquity::JsonImport::AddFiles.new(@file, @tenant_domain, @work_instance).attach_files
    end

  end
end
