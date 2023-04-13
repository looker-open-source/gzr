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
        say_error e
        say_error e.errors if e.errors
        raise
      end
      data
    end
    def query_role(role_id)
      data = nil
      begin
        data = @sdk.role(role_id)
      rescue LookerSDK::NotFound => e
        # do nothing
      rescue LookerSDK::ClientError => e
        say_error "Unable to get role(#{role_id})"
        say_error e
        say_error e.errors if e.errors
        raise
      end
      data
    end
    def delete_role(role_id)
      data = nil
      begin
        data = @sdk.delete_role(role_id)
      rescue LookerSDK::NotFound => e
        # do nothing
      rescue LookerSDK::ClientError => e
        say_error "Unable to delete_role(#{role_id})"
        say_error e
        say_error e.errors if e.errors
        raise
      end
      data
    end
    def query_role_groups(role_id,fields=nil)
      req = Hash.new
      req[:fields] = fields if fields
      data = Array.new
      begin
        data = @sdk.role_groups(role_id, req)
      rescue LookerSDK::NotFound => e
        # do nothing
      rescue LookerSDK::ClientError => e
        say_error "Unable to get role_groups(#{role_id},#{JSON.pretty_generate(req)})"
        say_error e
        say_error e.errors if e.errors
        raise
      end
      data
    end
    def query_role_users(role_id,fields=nil,direct_association_only=true)
      req = Hash.new
      req[:fields] = fields if fields
      req[:direct_association_only] = direct_association_only
      data = Array.new
      begin
        data = @sdk.role_users(role_id, req)
      rescue LookerSDK::NotFound => e
        # do nothing
      rescue LookerSDK::ClientError => e
        say_error "Unable to get role_users(#{role_id},#{JSON.pretty_generate(req)})"
        say_error e
        say_error e.errors if e.errors
        raise
      end
      data
    end
    def set_role_groups(role_id,groups=[])
      data = Array.new
      begin
        data = @sdk.set_role_groups(role_id, groups)
      rescue LookerSDK::ClientError => e
        say_error "Unable to call set_role_groups(#{role_id},#{JSON.pretty_generate(groups)})"
        say_error e
        say_error e.errors if e.errors
        raise
      end
      data
    end
    def set_role_users(role_id,users=[])
      data = Array.new
      begin
        data = @sdk.set_role_users(role_id, users)
      rescue LookerSDK::ClientError => e
        say_error "Unable to call set_role_users(#{role_id},#{JSON.pretty_generate(users)})"
        say_error e
        say_error e.errors if e.errors
        raise
      end
      data
    end
  end
end
