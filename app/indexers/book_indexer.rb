# Generated via
#  `rails generate hyrax:work Book`
class BookIndexer < SharedIndexer
  # This indexes the default metadata. You can remove it if you want to
  # provide your own metadata and indexing.
  include Hyrax::IndexesBasicMetadata

  # Fetch remote labels for based_near. You can remove this if you don't want
  # this behavior
  include Hyrax::IndexesLinkedMetadata

  # Adding custom indexing behavior for the editor column, added as part of the OAI Harvesting
  def generate_solr_document
    super.tap do |solr_doc|
      solr_doc[Solrizer.solr_name('editor_list', :stored_searchable)] = Ubiquity::ParseJson.new(object.editor.first).fetch_value_based_on_key('editor')
    end
  end
end
