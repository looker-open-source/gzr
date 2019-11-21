# The MIT License (MIT)

# Copyright (c) 2018 Mike DeAngelo Looker Data Sciences, Inc.

# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
# the Software, and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
# FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
# IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# frozen_string_literal: true

module Gzr
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
    
    def search_groups(name)
      req = {:name => name }
      begin
        return @sdk.search_groups(req)
      rescue LookerSDK::NotFound => e
        return nil
      rescue LookerSDK::ClientError => e
        say_error "Unable to search_groups(#{JSON.pretty_generate(req)})"
        say_error e.message
        raise
      end
    end
    
    def query_group(id, fields=nil)
      req = Hash.new
      req[:fields] = fields if fields
      begin
        return @sdk.group(id,req)
      rescue LookerSDK::NotFound => e
        return nil
      rescue LookerSDK::ClientError => e
        say_error "Unable to find group(#{id},#{JSON.pretty_generate(req)})"
        say_error e.message
        raise
      end
    end
  end
end
