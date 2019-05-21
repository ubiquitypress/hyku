# Modify this method to changes the preselection for the Institute field
module Ubiquity
  module PreselectInstitutionHelper
    def fetch_institution_by_tenant
      tenant_name = ubiquity_url_parser request.original_url
      institution_hash = {
                            'British Library' => ['sandbox', 'sandbox2', 'bl'],
                            'MOLA' => ['sandbox2', 'mola', 'mola-demo'],
                            'National Museums Scotland' => ['nms', 'nms-demo'],
                            'British Museum' => ['britishmuseum', 'britishmuseum-demo'],
                            'Tate' => ['tate', 'tate-demo'],
                            'Kew' => ['kew', 'kew-demo']
                         }
      institution_hash.select { |_key, values| values.include?(tenant_name) }.keys.first
    end
  end
end
