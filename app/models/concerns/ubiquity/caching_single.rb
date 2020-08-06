module Ubiquity
  module CachingSingle
    extend ActiveSupport::Concern
    included do
      after_save :flush_single_cache
      after_destroy :flush_single_cache
    end

    def flush_single_cache
      fedora_cache_key
      burst_cache_key_containing_parent
      burst_work_files_cache
      clear_highlights_page_cache
      Rails.cache.delete(@fedora_cache)
      Rails.cache.delete(@thumbnail_cache)
      Rails.cache.delete(single_work_cache_key)
      Rails.cache.delete(single_collection_cache_key)
   end

   private

   def cache_key
     if self.class != SolrDocument
       return "#{self.class.model_name.cache_key}/new" if new_record?
       return "#{self.class.model_name.cache_key}/#{id}-#{date_modified.utc.to_s(:nsec)}" if date_modified
       "#{self.class.model_name.cache_key}/#{id}"
      end
    end

    def single_work_cache_key
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
      cache_type = self.class == Collection ? 'fedora/collection' : 'fedora/work'
      @fedora_cache = "single/#{cache_type}/#{self.account_cname}/#{self.id}"
      @thumbnail_cache = "single/#{cache_type}-thumbnail/#{self.account_cname}/#{self.id}"
    end

    def get_parent_collection_cache
      if ENV['REDIS_CACHE_HOST'].present? && self.class != Collection
        $redis_cache.keys("parent_collection/#{self.account_cname}/#{self.id}/*")
      end
    end

    def burst_cache_key_containing_parent
      @parent_keys = get_parent_collection_cache
      if @parent_keys.present?
        @parent_keys.each do |key|
          $redis_cache.del(key)
         end
       end
     end

     def get_work_files_cache
       if ENV['REDIS_CACHE_HOST'].present? && self.class != Collection
         $redis_cache.keys("work_files/#{self.account_cname}/#{self.id}/*")
       end
     end

     def burst_work_files_cache
       @file_keys = get_work_files_cache
       if @pfile_keys.present?
         @file_keys.each do |key|
           $redis_cache.del(key)
          end
        end
      end

     def highlights_page_cache
       if ENV['REDIS_CACHE_HOST'].present?
         $redis_cache.keys("multiple/highlights/#{self.account_cname}/*")
       end
     end

     def clear_highlights_page_cache
       @highlights_keys ||= highlights_page_cache
       if  @highlights_keys.present?
         @highlights_keys.each do |key|
           $redis_cache.del(key)
         end
       end
     end

  end
end