module Ubiquity
  module CollectionListPerPage
    Hyrax::CollectionMemberSearchBuilder.class_eval do
      def member_of_collection(solr_parameters)
        solr_parameters[:fq] ||= []
        solr_parameters[:fq] << "#{collection_membership_field}:#{collection_id}"
        solr_parameters[:rows] = 100
      end
    end
  end
end
