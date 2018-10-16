require "global_id"

#Fix for Unsupported argument type: RDF::URI (ActiveJob::SerializationError)
ActiveFedora::Base.send :include, GlobalID::Identification
