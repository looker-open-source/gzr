# frozen_string_literal: true

module Gzr
  module Role
    def query_all_roles(fields=nil)
      req = Hash.new
      req[:fields] = fields if fields
      data = Array.new
      begin
        data = @sdk.all_roles(req)
      rescue LookerSDK::NotFound => e
        # do nothing
      rescue LookerSDK::ClientError => e
        say_error "Unable to get all_roles(#{JSON.pretty_generate(req)})"
        say_error e.message
        say_error e.errors if e.errors
        raise
      end
      data
    end
  end
end
