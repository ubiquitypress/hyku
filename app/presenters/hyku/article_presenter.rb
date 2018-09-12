module Hyku
  class ArticlePresenter < ManifestEnabledWorkShowPresenter


  # Override to inject work_type for proper i18n lookup
  def attribute_to_html(field, options = {})
    options[:html_dl] = true
    options[:work_type] = 'article'
    super
  end

  end
end
