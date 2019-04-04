module Ubiquity
  class DataciteController < ApplicationController

    def create

      render json: {"suffix": "#{ENV["datacite_prefix"]}/num"}

    end
  end
end
