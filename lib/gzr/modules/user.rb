# frozen_string_literal: true

module Gzr
  module User

    def query_me(fields=nil)
      data = nil
      begin
        data = @sdk.me(fields ? {:fields=>fields} : nil )
      rescue LookerSDK::Error => e
        say_error "Error querying me({:fields=>\"#{fields}\"})"
        say_error e.message
        raise
      end
      data
    end

    def query_user(id,fields=nil)
      data = nil
      begin
        data = @sdk.user(id, fields ? {:fields=>fields} : nil )
      rescue LookerSDK::Error => e
        say_error "Error querying user(#{id},{:fields=>\"#{fields}\"})"
        say_error e.message
        raise
      end
      data
    end

    def search_users(filter, fields=nil, sorts=nil)
      req = {
        :per_page=>128
      }
      req.merge!(filter)
      req[:fields] = fields if fields
      req[:sorts] = sorts if sorts

      data = Array.new
      page = 1
      loop do
        begin
          req[:page] = page
          scratch_data = @sdk.search_users(req)
        rescue LookerSDK::ClientError => e
          say_error "Unable to get search_users(#{JSON.pretty_generate(req)})"
          say_error e.message
          raise
        end
        break if scratch_data.length == 0
        page += 1
        data += scratch_data
      end
      data
    end

    def query_all_users(fields=nil, sorts=nil)
      req = {
        :per_page=>128
      }
      req[:fields] = fields if fields
      req[:sorts] = sorts if sorts

      data = Array.new
      page = 1
      loop do
        begin
          req[:page] = page
          scratch_data = @sdk.all_users(req)
        rescue LookerSDK::ClientError => e
          say_error "Unable to get all_users(#{JSON.pretty_generate(req)})"
          say_error e.message
          raise
        end
        break if scratch_data.length == 0
        page += 1
        data += scratch_data
      end
      data
    end

    def update_user(id,req)
      data = nil
      begin
        data = @sdk.update_user(id,req)
      rescue LookerSDK::Error => e
        say_error "Error updating user(#{id},#{JSON.pretty_generate(req)})"
        say_error e.message
        raise
      end
      data
    end
  end
end
