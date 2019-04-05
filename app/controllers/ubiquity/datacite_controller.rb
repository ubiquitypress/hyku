module Ubiquity
  class DataciteController < ApplicationController


    def create
      render json: {"draft_doi": "#{ENV["datacite_prefix"]}/#{}"}
    end

  end
end
