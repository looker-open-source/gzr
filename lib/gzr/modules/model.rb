# frozen_string_literal: true

module Gzr
  module Model
    def query_all_lookml_models(fields=nil)
      data = nil
      begin
        req = Hash.new
        req[:fields] = fields if fields
        data = @sdk.all_lookml_models(req)
      rescue LookerSDK::Error => e
        say_error "Error querying all_lookml_models(#{JSON.pretty_generate(req)})"
        say_error e.message
        raise
      end
      data
    end
  end
end
