module Ubiquity
  class ApiError < StandardError

    attr_reader :status, :code, :message, :error_hash

    #raises this when it is unable to read JSON request payload
    BadRequest = Class.new(self)

    #When access_token is invalid, Microsoft raises CompactToken validation failed
    Unauthorized = Class.new(self)

    # Raised when Microsoft returns the HTTP status code 403
    Forbidden = Class.new(self)

    # Raised when Microsoft returns the HTTP status code 404
    NotFound = Class.new(self)

    # Raised when Microsoft returns the HTTP status code 406
    NotAcceptable = Class.new(self)

    def initialize(status: '', code: '', message: '')
      @status = status
      @code = code
      @message = message
      @error_hash = {message: message, code: code, status:  status}
      super
    end

  end

end
