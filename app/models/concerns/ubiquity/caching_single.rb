module Ubiquity
  module CachingSingle
    extend ActiveSupport::Concern

    included do
      after_save :flush_single_cache
    end

    def cache_key
      if self.class != SolrDocument
      return "#{self.class.model_name.cache_key}/new" if new_record?
      return "#{self.class.model_name.cache_key}/#{id}-#{date_modified.utc.to_s(:nsec)}" if date_modified
      "#{self.class.model_name.cache_key}/#{id}"
      end
    end

    def single_work_cache_key
      puts "sabi #{self.class}"
      if self.class != Collection
        "single/work/#{self.account_cname}/#{self.id}"
      end
    end

    def single_collection_cache_key
      if self.class == Collection
        "single/collection/#{self.account_cname}/#{self.id}"
      end
    end

    def fedora_cache_key
      cache_type = record.class == Collection ? 'fedora/collection' : 'fedora/work'
      "single/#{cache_type}/#{self.account_cname_tesim}/#{self.id}"
    end

    # def solr_cache_key
    #   if self.class == SolrDocument
    #   return "#{self.class.model_name.cache_key}/new" if new_record?
    #   return "#{self.class.model_name.cache_key}/#{id}-#{date_modified.utc.to_s(:nsec)}" if date_modified
    #   "#{self.class.model_name.cache_key}/#{id}"
    #   end
    # end

    def add_to_cache
      #Rails.cache.fetch(cache_key)
    end

    def flush_single_cache
      Rails.cache.delete(fedora_cache_key)
      Rails.cache.delete(single_work_cache_key)
      Rails.cache.delete(single_collection_cache_key)
    end

  end
end
