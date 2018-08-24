require 'json'

module Hyrax
  module Renderers
    class CreatorAttributeRenderer < AttributeRenderer

      def initialize(field, values, options = {})
        puts "my-values #{values}"

        #value is  creator
        @field = field
        puts "ini-field #{@field}"
        #array containing json sring, which when passed is an array of hashes
        @values = values
        #@values = parse_value(values)
        puts "ini-values #{@values}"

        #value is {:render_as=>:creator}
        @options = options

        puts "ini-options #{@options}"
        super
      end

      def attribute_value_to_html(value)

        %(<span itemprop="creator"><a href="creator: #{value}"> biggie #{value}</a></span>)
      #  %(<span itemprop="creator"><a href="creator: #{value}">  #{value} </a></span>)
        super
      end

      def parse_value(value)
        #use when we called from attribute_vale_to_html
        #returns a single array of hashes
        new_value = JSON.parse(value)

        #used when called from initialize
        #new_value = JSON.parse(value.first)

        #puts "new-value: #{new_value.class}"
        #puts "first hash in array : #{new_value.first}"

        new_value.each do |hash|

        #puts "suna: #{hash['creator_given_name']} "
          #{}%(<span itemprop="creator> <a href="creator: #{value}"> ubiquity #{hash['creator_given_name']}  ( #{hash['creator_orcid']} )  </a>  </span>)
        end
      end

      private

      def html_attributes(attributes)
        puts "html-is #{attributes}"
        super
      end

    end
  end
end
