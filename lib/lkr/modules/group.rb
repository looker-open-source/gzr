# frozen_string_literal: true

module Lkr
  module Group
    def query_all_groups(fields=nil, sorts=nil)
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
          scratch_data = @sdk.all_groups(req)
        rescue LookerSDK::ClientError => e
          say_error "Unable to get all_groups(#{JSON.pretty_generate(req)})"
          say_error e.message
          raise
        end
        break if scratch_data.length == 0
        page += 1
        data += scratch_data
      end
      data
    end
    
    def query_group_groups(group_id,fields=nil)
      req = { }
      req[:fields] = fields if fields

      data = Array.new
      begin
        data = @sdk.all_group_groups(group_id,req)
      rescue LookerSDK::NotFound => e
        return []
      rescue LookerSDK::ClientError => e
        say_error "Unable to get all_group_groups(#{group_id},#{JSON.pretty_generate(req)})"
        say_error e.message
        raise
      end
      data
    end

    def query_group_users(group_id,fields=nil,sorts=nil)
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
          scratch_data = @sdk.all_group_users(group_id,req)
        rescue LookerSDK::ClientError => e
          say_error "Unable to get all_group_users(#{group_id},#{JSON.pretty_generate(req)})"
          say_error e.message
          raise
        end
        break if scratch_data.length == 0
        page += 1
        data += scratch_data
      end
      data
    end
  end
end
