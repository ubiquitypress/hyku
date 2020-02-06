require 'jwt'

module Ubiquity
  class Api::JwtGenerator
    SEKRET = Rails.application.secrets.secret_key_base

    #payload eg {user: 3}
    def self.encode(payload)
      payload.merge!(exp: (Time.now + 1.hours).to_i) if payload[:exp].nil?
      JWT.encode(payload, SEKRET)
    end

    def self.decode(token)
      JWT.decode(token, SEKRET).try(:first)
    end

  end
end
