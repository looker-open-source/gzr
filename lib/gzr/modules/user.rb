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
    
    def delete_user(id)
      data = nil
       req = id
      begin
        data = @sdk.delete_user(req)
      rescue LookerSDK::Error => e
        say_error "Error deleting user(#{id},#{JSON.pretty_generate(req)})"
        say_error e.message
        raise
      end
      data
    end
  end
end
