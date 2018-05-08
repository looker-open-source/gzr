# frozen_string_literal: true

module Lkr
  module Look
    def query_look(look_id)
      data = nil
      begin
        data = @sdk.look(look_id)
      rescue LookerSDK::Error => e
          say_error "Error querying look(#{look_id})"
          say_error e.message
          raise
      end
      data
    end

    def delete_look(look_id)
      data = nil
      begin
        data = @sdk.delete_look(look_id)
      rescue LookerSDK::Error => e
          say_error "Error deleting look(#{look_id})"
          say_error e.message
          raise
      end
      data
    end

    def search_looks(title, space_id=nil)
      data = nil
      begin
        req = { :title => title }
        req[:space_id] = space_id if space_id 
        data = @sdk.search_looks(req)
      rescue LookerSDK::Error => e
        say_error "Error  search_looks(#{JSON.pretty_generate(req)})"
          say_error e.message
          raise
      end
      data
    end

    def create_look(look)
      begin
        data = @sdk.create_look(look)
      rescue LookerSDK::Error => e
          say_error "Error creating look"
          say_error e.message
          raise
      end
      data
    end
  end
end