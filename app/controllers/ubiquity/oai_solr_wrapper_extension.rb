# Overriding OaiSolrWrapperExtension for filtering OAI records which is public

module Ubiquity
  module OaiSolrWrapperExtension
    extend ActiveSupport::Concern

    def find(selector, options = {})
      return next_set(options[:resumption_token]) if options[:resumption_token]

      if selector == :all
        response = @controller.repository.search(conditions(options))

        if limit && response.total > limit
          return select_partial(BlacklightOaiProvider::ResumptionToken.new(options.merge(last: 0), nil, response.total))
        end
        response.documents
      else
        record = @controller.fetch(selector).first.documents.first
        if record.public? && record['workflow_state_name_ssim'].try(:first) != 'pending_review'
          record
        end
      end
    end

    private def conditions(options) # conditions/query derived from options
      query = @controller.search_builder.merge(sort: "#{solr_timestamp} asc", rows: limit).query
      if options[:from].present? || options[:until].present?
        query.append_filter_query(
          "#{solr_timestamp}:[#{solr_date(options[:from])} TO #{solr_date(options[:until]).gsub('Z', '.999Z')}]"
        )
      end
      query.append_filter_query('read_access_group_ssim:public') # Fetching only public records
      query
    end
  end
end
