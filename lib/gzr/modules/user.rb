# The MIT License (MIT)

# Copyright (c) 2023 Mike DeAngelo Google, Inc.

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

    def query_me(fields='id')
      begin
        @sdk.me(fields ? {:fields=>fields} : nil ).to_attrs
      rescue LookerSDK::Error => e
        say_error "Error querying me({:fields=>\"#{fields}\"})"
        say_error e
        raise
      end
    end

    def query_user(id,fields='id')
      begin
        @sdk.user(id, fields ? {:fields=>fields} : nil ).to_attrs
      rescue LookerSDK::NotFound => e
        say_error "user(#{id}) not found"
        say_error e
        raise
      rescue LookerSDK::Error => e
        say_error "Error querying user(#{id},{:fields=>\"#{fields}\"})"
        say_error e
        raise
      end
    end

    def search_users(filter, fields=nil, sorts=nil)
      req = {
        :limit=>64
      }
      req.merge!(filter)
      req[:fields] = fields if fields
      req[:sorts] = sorts if sorts

      data = Array.new
      begin
        loop do
          page = @sdk.search_users(req).collect { |r| r.to_attrs }
          data+=page
          break unless page.length == req[:limit]
          req[:offset] = (req[:offset] || 0) + req[:limit]
        end
      rescue LookerSDK::NotFound => e
        # do nothing
      rescue LookerSDK::ClientError => e
        say_error "Unable to get search_users(#{JSON.pretty_generate(req)})"
        say_error e
        raise
      end
      data
    end

    def query_all_users(fields=nil, sorts=nil)
      req = {
        :limit=>64
      }
      req[:fields] = fields if fields
      req[:sorts] = sorts if sorts

      data = Array.new
      begin
        loop do
          page = @sdk.all_users(req).collect { |r| r.to_attrs }
          data+=page
          break unless page.length == req[:limit]
          req[:offset] = (req[:offset] || 0) + req[:limit]
        end
      rescue LookerSDK::NotFound => e
        # do nothing
      rescue LookerSDK::ClientError => e
        say_error "Unable to get all_users(#{JSON.pretty_generate(req)})"
        say_error e
        raise
      end
      data
    end

    def update_user(id,req)
      begin
        @sdk.update_user(id,req)&.to_attrs
      rescue LookerSDK::NotFound => e
        say_error "updating user(#{id},#{JSON.pretty_generate(req)}) not found"
        say_error e
        raise
      rescue LookerSDK::Error => e
        say_error "Error updating user(#{id},#{JSON.pretty_generate(req)})"
        say_error e
        raise
      end
    end

    def delete_user(id)
      begin
        @sdk.delete_user(id)
      rescue LookerSDK::NotFound => e
        say_error "delete user(#{id},#{JSON.pretty_generate(req)}) not found"
        say_error e
        raise
      rescue LookerSDK::Error => e
        say_error "Error deleting user(#{id})"
        say_error e
        raise
      end
    end

    def trim_user(data)
      data.select do |k,v|
        (keys_to_keep('create_user') + [:id]).include? k
      end
    end
  end
end
