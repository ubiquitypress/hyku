module Ubiquity
  class SolrModelWrapper
    attr_accessor :model, :id
    def initialize(model, id)
      @model = model
      @id = id
    end
  end
end
