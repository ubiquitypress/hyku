class AdditionalCitations < ApplicationRecord
  def doi_regex
    %r{10.\d{4,9}\/[-._;()\/:A-Z0-9]+/i}
  end

  def isbn_regex
    %r{(ISBN[ ]?)*(97[\d]{11})|(\d{9}[\d|X]{1})/i}
  end

  def identifiers_str(presenter)
    presenter.join(' ').delete('-')
  end

  def doi(presenter)
    identifiers_str(presenter).scan(doi_regex).join
  end

  def isbn(presenter)
    isbn_str = identifiers_str(presenter).delete(doi_regex)
    isbn_str.scan(isbn_regex).map(&:compact)
  end
end
