module Ubiquity
  class CrossrefClient
    include HTTParty
    include Ubiquity::SharedDataciteCrossrefMethods
  end
end
