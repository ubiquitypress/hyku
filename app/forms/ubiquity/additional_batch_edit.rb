# Defined in https://github.com/samvera/hyrax/blob/v2.0.2/app/forms/hyrax/forms/batch_edit_form.rb
# In order to Add more fields to batch edit
  module Ubiquity
    #to do :version, not to be added until investigation is done as to why it is throwing an error
    module AdditionalBatchEdit

      new_terms = [:institution, :date_published, :place_of_publication, :issn, :eissn, :isbn]
     Hyrax::Forms::BatchEditForm.terms += new_terms
      Hyrax::Forms::BatchEditForm.terms -= [:creator, :contributor, :subject, :identifier, :location, :date_created]

#   # override this method if you need to initialize more complex RDF assertions (b-nodes)
#    # @return [Hash<String, Array>] the list of unique values per field
   private
    def initialize_combined_fields
      # For each of the files in the batch, set the attributes to be the concatenation of all the attributes
      batch_document_ids.each_with_object({}) do |doc_id, combined_attributes|
        work = ActiveFedora::Base.find(doc_id)
        terms.each do |field|
          combined_attributes[field] ||= []
          work_field = work.try(field).try(:to_a) if work.try(field).present?
          if  work_field.present?
            combined_attributes[field] = (combined_attributes[field] +  work_field ).uniq
          end
       end
       names << work.to_s
      end
    end

   end
 end


# Hyrax::Forms::BatchEditForm.class_eval do
#    new_terms = [:institution, :title, :doi, :rights_statement, :editor]
#    self.terms += new_terms
#
#    # override this method if you need to initialize more complex RDF assertions (b-nodes)
#    # @return [Hash<String, Array>] the list of unique values per field
#    def initialize_combined_fields
#      # For each of the files in the batch, set the attributes to be the concatenation of all the attributes
#      batch_document_ids.each_with_object({}) do |doc_id, combined_attributes|
#        work = ActiveFedora::Base.find(doc_id)
#        terms.each do |field|
#
#          combined_attributes[field] ||= []
#          work_field = work.try(field).to_a if work.try(field).present?
#          #combined_attributes[field] = (combined_attributes[field] +  work.try(:field).try(:to_a) ).uniq
#          if  work_field.present?
#            combined_attributes[field] = (combined_attributes[field] +  work_field ).uniq
#          end
#        end
#        names << work.to_s
#      end
#    end
#
#  end
