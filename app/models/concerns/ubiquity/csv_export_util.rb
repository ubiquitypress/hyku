module Ubiquity
  module CsvExportUtil
    extend ActiveSupport::Concern
    DEFAULT_WORK = [Article, Book, BookContribution, ConferenceItem, Dataset, Image, Report, GenericWork]

    #def get_csv_data(klass)
      #self.class.csv_header(klass).map do |key|
    def get_csv_data
      self.class.csv_header.map do |key|
        #puts "somi #{self.send(key)}" if key == "id"
        #self.send(key)
        value = self.send(key)
        puts "key #{key}"
        puts "taco #{value.inspect} == #{key}"
        #puts "self #{self.inspect}"
        #puts "value inspect #{value.inspect}"
        #puts "value #{value}"
        #@id = key if key == "id"
        #@object ||= ActiveFedora::Base.send('find', @id
        #@object.send(key)

        if  (value != key && value.present? && value.class == String)
          puts "talk #{value} == #{key}"
          b = value
          #puts "string value #{b}"

          b
        elsif ((value != key && value.present? && value.class == ActiveTriples::Relation || value.class == Array) && (not ['creator', 'editor', 'contributor', 'alternate_identifier', 'related_identifier'].include? key) )
          c = value.join('||').strip
            #puts "array value #{c}"
            #puts "array value #{c.inspect}"
          c
        elsif (value != key && value.present? && (['creator', 'editor', 'contributor', 'alternate_identifier', 'related_identifier'].include? key) )
          #problem displays <ActiveTriples::Relation:0x007f1f147e6ca8>
          #when just value is returned
          d = value.first
          #puts "json value #{d}"
          d
        end
      end
    end

    class_methods do

      #def csv_header(klass)
      def csv_header
        removed_keys = ["head", "tail","proxy_depositor", "on_behalf_of", "arkivo_checksum", "owner",  "version", "label", "relative_path", "import_url", "based_near", "identifier", "access_control_id", "representative_id", "thumbnail_id", "admin_set_id", "embargo_id", "lease_id", "bibliographic_citation", "state",  "creator_search"]
        header_keys = self.attribute_names - removed_keys
        #header_keys = klass.attribute_names - removed_keys
        header_keys.unshift("id")
        header_keys.push('files')
      end

      def csv_data
          #find_each do |object|
          all.map do |object|
            object.get_csv_data
          end
      end

      def export_models(klass=DEFAULT_WORK)
        klass.each do |model|
          to_csv_final(model)
        end
      end

      def to_csv_final(model)
        #csv = CSV.generate(headers: true){}
         csv = CSV.new('', headers: csv_header)
         #CSV.new(data, headers: headers, write_headers: true, return_headers: true)

      end

      def to_csv
        removed_keys = ["head", "tail","proxy_depositor", "on_behalf_of", "arkivo_checksum", "owner",  "version", "label", "relative_path", "import_url", "based_near", "identifier", "access_control_id", "representative_id", "thumbnail_id", "admin_set_id", "embargo_id", "lease_id", "bibliographic_citation", "state",  "creator_search"]
        header_keys = self.attribute_names - removed_keys
        header_keys.unshift("id")
        header_keys.push('files')

        #, row_sep: nil (headers: true)#
        b = CSV.generate(headers: true) do |csv|
          csv << header_keys
          puts "headers #{csv.inspect}"
          file_names = []
          all.each do |object|
            file_names = object.file_sets.map { |file| file.title.first} if object.file_sets.present?
            x = file_names.join(',')
            #csv << object.attributes.values_at(*header_keys)
            needed_attributes = object.attributes.except!(*removed_keys)
            puts "needed #{needed_attributes.keys}"

            k = needed_attributes.map do |key, value|
              new_array = []
              puts "nama #{ needed_attributes[key]}" if key == "id"
              u = []
              s = []
              z = []
              u << needed_attributes.values_at(key) if  (value.present? && value.class == String)

              s << [value.join('||').strip] if (value.present? && value.class == ActiveTriples::Relation && (not ['creator', 'editor', 'contributor', 'alternate_identifier', 'related_identifier'].include? key) )

              z << needed_attributes[key].to_a if (value.present? && (['creator', 'editor', 'contributor', 'alternate_identifier', 'related_identifier'].include? key) )

              #z.concat(u).concat(s).concat(file_names).join(',')

                z.concat(u).concat(s).join(',')


              #z.concat(u).concat(s).first

              #new_array << [needed_attributes[key] ] if  (value.present? && value.class == String)

              ###new_array << needed_attributes.values_at(key) if  (value.present? && value.class == String)

              #new_array << [needed_attributes[key] ] if  (value.present? && value.class == String)

              #new_array << [value.join('||').strip] if (value.present? && value.class == ActiveTriples::Relation && (not ['creator', 'editor', 'contributor', 'alternate_identifier', 'related_identifier'].include? key) )

              ##new_array << [value.to_a.join('||').strip] if (value.present? && value.class == ActiveTriples::Relation && (not ['creator', 'editor', 'contributor', 'alternate_identifier', 'related_identifier'].include? key) )

              #new_array << needed_attributes[key] if (value.present? && (['creator', 'editor', 'contributor', 'alternate_identifier', 'related_identifier'].include? key) )

              #another
              #puts object.send(key) if (value.present? && value.class == ActiveTriples::Relation && (not ['creator', 'editor', 'contributor', 'alternate_identifier', 'related_identifier'].include? key) )

              #new_array << [object.send(key).join('||').strip] if (value.present? && value.class == ActiveTriples::Relation && (not ['creator', 'editor', 'contributor', 'alternate_identifier', 'related_identifier'].include? key) )

               #new_array
              #new_array.join(',')
              #csv << new_array
            end
            puts "kkk #{k}"
            puts "fila #{file_names}"
            k << x
            csv << k
            #csv << new_array
          end

        end
      end

      def to_csv_2
        removed_keys = ["head", "tail","proxy_depositor", "on_behalf_of", "arkivo_checksum", "owner",  "version", "label", "relative_path", "import_url", "based_near", "identifier", "access_control_id", "representative_id", "thumbnail_id", "admin_set_id", "embargo_id", "lease_id", "bibliographic_citation", "state",  "creator_search"]
        header_keys = self.attribute_names - removed_keys
        header_keys.unshift("id")
        header_keys.push('files')

        #, row_sep: nil (headers: true)#
        b = CSV.generate(headers: true) do |csv|
          csv << header_keys
          puts "headers #{csv.inspect}"
          file_names = []
          all.each do |object|
            file_names = object.file_sets.map { |file| file.title.first} if object.file_sets.present?

            #csv << object.attributes.values_at(*header_keys)
            needed_attributes = object.attributes.except!(*removed_keys)
            needed_attributes.merge!({"files" => file_names})
            puts "needed #{needed_attributes.keys}"

            k = needed_attributes.map do |key, value|
              new_array = []
              puts "nama #{ needed_attributes[key]}" if key == "id"
              puts "suna #{ needed_attributes[key].class}" if key == "files"
              u = []
              s = []
              z = []
              u << needed_attributes.values_at(key) if  (value.present? && value.class == String)

              s << [value.join('||').strip] if (value.present? && (value.class == ActiveTriples::Relation || value.class == Array) && (not ['creator', 'editor', 'contributor', 'alternate_identifier', 'related_identifier'].include? key) )

              z << needed_attributes[key].to_a if (value.present? && (['creator', 'editor', 'contributor', 'alternate_identifier', 'related_identifier'].include? key) )

              #z.concat(u).concat(s).concat(file_names).join(',')
              z.concat(u).concat(s).join(',')

            end
            puts "kkk #{k}"
            file_names.clear
            puts "fila #{file_names}"

             csv << k

          end

        end
      end

      def to_csv_3
        removed_keys = ["head", "tail","proxy_depositor", "on_behalf_of", "arkivo_checksum", "owner",  "version", "label", "relative_path", "import_url", "based_near", "identifier", "access_control_id", "representative_id", "thumbnail_id", "admin_set_id", "embargo_id", "lease_id", "bibliographic_citation", "state",  "creator_search"]
        header_keys = self.attribute_names - removed_keys
        header_keys.unshift("id")
        header_keys.push('files')

        #, row_sep: nil (headers: true)#
        b = CSV.generate(headers: true) do |csv|
          csv << header_keys
          puts "headers #{csv.inspect}"
          file_names = []


          all.each_with_index do |object, index|
            file_names = object.file_sets.map { |file| file.title.first} if object.file_sets.present?
            object.attributes.merge!({"files" => file_names})

            needed_attributes = object.attributes.except(*removed_keys)


            puts "needed #{needed_attributes}"
            puts "objecti #{object.inspect}"
            puts "object_id #{object.id}"
            puts "objectu? #{object.id.present?}"

            puts "indexo #{index}"

            k = needed_attributes.map do |key, value|
              new_array = []

              puts "nama #{ needed_attributes[key]}"
              puts "suna #{ needed_attributes[key].class}"

              #new_array << [needed_attributes[key] ] if  (value.present? && value.class == String)

              new_array << needed_attributes.values_at(key) if  (value.present? && value.class == String)
               #puts "new_array string #{new_array}"
              new_array << [value.join('||').strip] if (value.present? && (value.class == ActiveTriples::Relation || value.class == Array) && (not ['creator', 'editor', 'contributor', 'alternate_identifier', 'related_identifier'].include? key) )
               #puts "new_array array #{new_array}"
              ##new_array << [value.to_a.join('||').strip] if (value.present? && value.class == ActiveTriples::Relation && (not ['creator', 'editor', 'contributor', 'alternate_identifier', 'related_identifier'].include? key) )

              new_array << needed_attributes[key].to_a if (value.present? && (['creator', 'editor', 'contributor', 'alternate_identifier', 'related_identifier'].include? key) )

              new_array.reject {|j| j == [] || [[""]]}
              puts "new_array_j  #{new_array}"


              new_array.join(',')

            end
            puts "kkk #{k}"
            file_names.clear
            puts "fila #{file_names}"

            csv << k
          end

        end
      end

      def render_csv
        @csv_use = []
        puts "csviro #{@csv_use}"
        to_csv_4

        puts "csviro #{@csv_use}"
          @csv_use
      end

      def to_csv_4
        removed_keys = ["head", "tail","proxy_depositor", "on_behalf_of", "arkivo_checksum", "owner",  "version", "label", "relative_path", "import_url", "based_near", "identifier", "access_control_id", "representative_id", "thumbnail_id", "admin_set_id", "embargo_id", "lease_id", "bibliographic_citation", "state",  "creator_search"]
        header_keys = self.attribute_names - removed_keys
        header_keys.unshift("id")
        header_keys.push('files')

        #, row_sep: nil (headers: true)#
        b = CSV.generate(headers: true) do |csv|
          csv << header_keys
          #puts "headers #{csv.inspect}"
          file_names = []

          #all.each_with_index do |object, index|
          self.find_each do |object|
            puts "obu_title #{object.title.inspect}"
            file_names = object.file_sets.map { |file| file.title.first} if object.file_sets.present?
            object.attributes.merge!({"files" => file_names})

            needed_attributes = object.attributes.except(*removed_keys)

            #puts "needed #{needed_attributes}"
            #puts "objecti #{object.inspect}"
            #puts "object_id #{object.id}"
            #puts "objectu? #{object.id.present?}"

            #k = object.attributes.except(*removed_keys).map do |key, value|
            k = needed_attributes.map do |key, value|
              new_array = []

              #puts "nama #{ needed_attributes[key]}"
              #puts "suna #{ needed_attributes[key].class}"

              #new_array << [needed_attributes[key] ] if  (value.present? && value.class == String)
              new_array << needed_attributes.values_at(key) if  (value.present? && value.class == String)

               #puts "new_array string #{new_array}"
              new_array << [value.join('||').strip] if (value.present? && (value.class == ActiveTriples::Relation || value.class == Array) && (not ['creator', 'editor', 'contributor', 'alternate_identifier', 'related_identifier'].include? key) )
               #puts "new_array array #{new_array}"
              ##new_array << [value.to_a.join('||').strip] if (value.present? && value.class == ActiveTriples::Relation && (not ['creator', 'editor', 'contributor', 'alternate_identifier', 'related_identifier'].include? key) )

              new_array << needed_attributes[key].to_a if (value.present? && (['creator', 'editor', 'contributor', 'alternate_identifier', 'related_identifier'].include? key) )

              #new_array.reject {|j| j == [] || [[""]]}
              #puts "new_array_j  #{new_array}"

              #new_array
             new_array.join(',')

            end
            #puts "kiki #{k.length}"
            #k.flatten.reject! {|h| h.first == ''}
            #puts "kiwi #{k.length}"
            #puts "kkk #{k.flatten}"
            file_names.clear
            #puts "fila #{file_names}"
             csv << k
            #@csv_use << csv
          end  #closes find_each

        end  #closes csv generate
        puts "bravo #{b}"
         b
      end

      def to_csv_5
        removed_keys = ["head", "tail","proxy_depositor", "on_behalf_of", "arkivo_checksum", "owner",  "version", "label", "relative_path", "import_url", "based_near", "identifier", "access_control_id", "representative_id", "thumbnail_id", "admin_set_id", "embargo_id", "lease_id", "bibliographic_citation", "state",  "creator_search"]
        header_keys = self.attribute_names - removed_keys
        header_keys.unshift("id")
        header_keys.push('files')

        #, row_sep: nil (headers: true)#
        b = CSV.generate(headers: true) do |csv|
          csv << header_keys
          #puts "headers #{csv.inspect}"
          file_names = []


          #all.each_with_index do |object, index|
          self.find_each do |object|
            puts "obu_title #{object.title.inspect}"
            file_names = object.file_sets.map { |file| file.title.first} if object.file_sets.present?
            object.attributes.merge!({"files" => file_names})

            needed_attributes = object.attributes.except(*removed_keys)

            #puts "needed #{needed_attributes}"
            #puts "objecti #{object.inspect}"
            #puts "object_id #{object.id}"
            #puts "objectu? #{object.id.present?}"

            #k = object.attributes.except(*removed_keys).map do |key, value|
            k = header_keys.map do |key|
              new_array = []

              #puts "nama #{ needed_attributes[key]}"
              #puts "suna #{ needed_attributes[key].class}"

              #new_array << [needed_attributes[key] ] if  (value.present? && value.class == String)
              ##new_array << needed_attributes.values_at(key) if  (value.present? && value.class == String)
              value = object.send(key)
              new_array << value if  (value.present? && value.class == String)


               #puts "new_array string #{new_array}"
              ##new_array << [value.join('||').strip] if (value.present? && (value.class == ActiveTriples::Relation || value.class == Array) && (not ['creator', 'editor', 'contributor', 'alternate_identifier', 'related_identifier'].include? key) )
               #puts "new_array array #{new_array}"
              new_array << [value.to_a.join('||').strip] if (value.present? && value.class == ActiveTriples::Relation && (not ['creator', 'editor', 'contributor', 'alternate_identifier', 'related_identifier'].include? key) )

              new_array << value.to_a if (value.present? && (['creator', 'editor', 'contributor', 'alternate_identifier', 'related_identifier'].include? key) )

              #new_array.reject {|j| j == [] || [[""]]}
              #puts "new_array_j  #{new_array}"

              new_array
              #new_array.join(',')

            end
            #puts "kiki #{k.length}"
            #k.flatten.reject! {|h| h.first == ''}
            #puts "kiwi #{k.length}"
            #puts "kkk #{k.flatten}"
            file_names.clear
            #puts "fila #{file_names}"


            csv << k
            #@csv_use << csv
          end

        end
          #@csv_use  << b
      end

      def to_csv_try

          CSV.generate do |csv|
            removed_keys = ["head", "tail","proxy_depositor", "on_behalf_of", "arkivo_checksum", "owner",  "version", "label", "relative_path", "import_url", "based_near", "identifier", "access_control_id", "representative_id", "thumbnail_id", "admin_set_id", "embargo_id", "lease_id", "bibliographic_citation", "state",  "creator_search"]
            header_keys = self.attribute_names - removed_keys
            header_keys.unshift("id")
            header_keys.push('files')

            csv << header_keys
            model_object.each do |object|
              csv << object.attributes.values_at(*header_keys)
            end
         end
     end

     def model_object
       all.each do |object|
         #object.attributes = object.attributes.except!(*removed_keys)
         file_names = object.file_sets.map { |file| file.title.first} if object.file_sets.present?
         object.attributes.merge!({"files" => file_names})

         #new_array << [value.join('||').strip] if (value.present? && (value.class == ActiveTriples::Relation || value.class == Array) && (not ['creator', 'editor', 'contributor', 'alternate_identifier', 'related_identifier'].include? key) )
         #array_values =  object.attributes.each {|key, value|  object.attributes[key] = [value.join('||').strip] if (value.present? && (value.class == ActiveTriples::Relation || value.class == Array) && (not ['creator', 'editor', 'contributor', 'alternate_identifier', 'related_identifier'].include? key) )}
         array_values =  object.attributes.map {|key, value|  object.attributes[key] = value.to_a.join('||').strip if (value.present? && (value.class == ActiveTriples::Relation || value.class == Array) && (not ['creator', 'editor', 'contributor', 'alternate_identifier', 'related_identifier'].include? key) )}
         #array_values =  object.attributes.map {|key, value|  puts value.class if (key == 'keyword' && value.present? && (value.class == ActiveTriples::Relation || value.class == Array) && (not ['creator', 'editor', 'contributor', 'alternate_identifier', 'related_identifier'].include? key) )}
         #array_values =  object.attributes.map {|key, value|  puts object.attributes[key] if (key == 'keyword')}

         #array_value =  object.attributes.map {|key, value|  puts value.to_a if (key == 'keyword')}

        #objecta = object.attributes.values_at(*header_keys)
        #csv << objecta

         #puts "objecta #{object.attributes}"
         #puts "arroyo #{array_values}"

       end
       all
     end

     def to_csv_
       CSV.generate do |csv|
         removed_keys = ["head", "tail","proxy_depositor", "on_behalf_of", "arkivo_checksum", "owner",  "version", "label", "relative_path", "import_url", "based_near", "identifier", "access_control_id", "representative_id", "thumbnail_id", "admin_set_id", "embargo_id", "lease_id", "bibliographic_citation", "state",  "creator_search"]
         header_keys = self.attribute_names - removed_keys
         header_keys.unshift("id")
         header_keys.push('files')

         csv << header_keys
         all.each do |object|
           #object.attributes = object.attributes.except!(*removed_keys)
           file_names = object.file_sets.map { |file| file.title.first} if object.file_sets.present?
           object.attributes.merge!({"files" => file_names})

           #new_array << [value.join('||').strip] if (value.present? && (value.class == ActiveTriples::Relation || value.class == Array) && (not ['creator', 'editor', 'contributor', 'alternate_identifier', 'related_identifier'].include? key) )
           #array_values =  object.attributes.each {|key, value|  object.attributes[key] = [value.join('||').strip] if (value.present? && (value.class == ActiveTriples::Relation || value.class == Array) && (not ['creator', 'editor', 'contributor', 'alternate_identifier', 'related_identifier'].include? key) )}
           array_values =  object.attributes.map {|key, value|  object.attributes[key] = value.to_a.join('||').strip if (value.present? && (value.class == ActiveTriples::Relation || value.class == Array) && (not ['creator', 'editor', 'contributor', 'alternate_identifier', 'related_identifier'].include? key) )}
           #array_values =  object.attributes.map {|key, value|  puts value.class if (key == 'keyword' && value.present? && (value.class == ActiveTriples::Relation || value.class == Array) && (not ['creator', 'editor', 'contributor', 'alternate_identifier', 'related_identifier'].include? key) )}
           #array_values =  object.attributes.map {|key, value|  puts object.attributes[key] if (key == 'keyword')}

           #array_value =  object.attributes.map {|key, value|  puts value.to_a if (key == 'keyword')}


          #objecta = object.attributes.values_at(*header_keys)
          #csv << objecta
           puts "objecta #{object.attributes}"
           #puts "arroyo #{array_values}"
           csv << object.attributes.values_at(*header_keys)
         end
      end
    end

     def to_csv_new
       CSV.generate do |csv|
         removed_keys = ["head", "tail","proxy_depositor", "on_behalf_of", "arkivo_checksum", "owner",  "version", "label", "relative_path", "import_url", "based_near", "identifier", "access_control_id", "representative_id", "thumbnail_id", "admin_set_id", "embargo_id", "lease_id", "bibliographic_citation", "state",  "creator_search"]
         header_keys = self.attribute_names - removed_keys
         header_keys.unshift("id")
         header_keys.push('files')
         csv << header_keys
         all.each do |object|
           csv << object.attributes.values_at(*header_keys)
         end
       end
     end

    end

  end
end
