
module Ubiquity
  module EditorMetadataModelConcern
    extend ActiveSupport::Concern
    include Ubiquity::AllModelsVirtualFields

    included do

      property :editor, predicate: ::RDF::Vocab::SCHEMA.Person do |index|
        index.as :stored_searchable
      end

      #This is used in the forms to populate fields that will be stored in json fields
      #The json fields in this case is called editor
      attr_accessor :editor_group
      before_save :save_editor
    end

    private

    def save_editor
      #remove Hash with empty values and nil
      clean_submitted_data ||= remove_hash_keys_with_empty_and_nil_values(self.editor_group)

      #Check if the hash keys are only those used for default values like position
      data = compare_hash_keys?(clean_submitted_data)

      if (self.editor_group.present? && clean_submitted_data.present? && !data )
        # remove hash that contains only default keys and values.
        new_editor_group = remove_hash_with_default_keys(clean_submitted_data)
        editor_json = new_editor_group.to_json
        self.editor = [editor_json]
      elsif  data == true || data == nil
        #save an empty array since the sunmitted data contains only default keys & values
        self.editor = []
      end
    end

  end
end
