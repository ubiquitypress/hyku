module Ubiquity
  class CrossrefClient
    include HTTParty
    include Ubiquity::DataciteCrossrefClient
  end
end
