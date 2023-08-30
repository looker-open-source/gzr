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
  module Role
    def query_all_roles(fields=nil)
      req = Hash.new
      req[:fields] = fields if fields
      begin
        @sdk.all_roles(req).collect { |r| r.to_attrs }
      rescue LookerSDK::NotFound => e
        []
      rescue LookerSDK::Error => e
        say_error "Unable to get all_roles(#{JSON.pretty_generate(req)})"
        say_error e
        say_error e.errors if e.errors
        raise
      end
    end

    def query_role(role_id)
      begin
        @sdk.role(role_id).to_attrs
      rescue LookerSDK::NotFound => e
        say_error "role(#{role_id}) not found"
        say_error e
        raise
      rescue LookerSDK::Error => e
        say_error "Unable to get role(#{role_id})"
        say_error e
        say_error e.errors if e.errors
        raise
      end
    end

    def trim_role(data)
      trimmed = data.select do |k,v|
        (keys_to_keep('create_role') + [:id]).include? k
      end
      trimmed[:permission_set] = data[:permission_set].select do |k,v|
        (keys_to_keep('create_permission_set') + [:id,:built_in,:all_access]).include? k
      end
      trimmed[:model_set] = data[:model_set].select do |k,v|
        (keys_to_keep('create_model_set') + [:id,:built_in,:all_access]).include? k
      end
      trimmed
    end

    def delete_role(role_id)
      begin
        @sdk.delete_role(role_id)
      rescue LookerSDK::NotFound => e
        say_error "role(#{role_id}) not found"
        say_error e
        raise
      rescue LookerSDK::Error => e
        say_error "Unable to delete_role(#{role_id})"
        say_error e
        say_error e.errors if e.errors
        raise
      end
    end

    def query_role_groups(role_id,fields=nil)
      req = Hash.new
      req[:fields] = fields if fields
      begin
        @sdk.role_groups(role_id, req).collect { |g| g.to_attrs }
      rescue LookerSDK::NotFound => e
        say_error "role_groups(#{role_id},#{JSON.pretty_generate(req)}) not found"
        say_error e
        raise
      rescue LookerSDK::Error => e
        say_error "Unable to get role_groups(#{role_id},#{JSON.pretty_generate(req)})"
        say_error e
        say_error e.errors if e.errors
        raise
      end
    end

    def query_role_users(role_id,fields=nil,direct_association_only=true)
      req = Hash.new
      req[:fields] = fields if fields
      req[:direct_association_only] = direct_association_only
      begin
        @sdk.role_users(role_id, req).collect { |u| u.to_attrs }
      rescue LookerSDK::NotFound => e
        say_error "role_users(#{role_id},#{JSON.pretty_generate(req)}) not found"
        say_error e
        say_error e.errors if e.errors
        raise
      rescue LookerSDK::Error => e
        say_error "Unable to get role_users(#{role_id},#{JSON.pretty_generate(req)})"
        say_error e
        say_error e.errors if e.errors
        raise
      end
    end

    def set_role_groups(role_id,groups=[])
      begin
        @sdk.set_role_groups(role_id, groups).collect { |g| g.to_attrs }
      rescue LookerSDK::NotFound => e
        say_error "set_role_groups(#{role_id},#{JSON.pretty_generate(groups)}) not found"
        say_error e
        say_error e.errors if e.errors
        raise
      rescue LookerSDK::Error => e
        say_error "Unable to call set_role_groups(#{role_id},#{JSON.pretty_generate(groups)})"
        say_error e
        say_error e.errors if e.errors
        raise
      end
    end

    def set_role_users(role_id,users=[])
      begin
        @sdk.set_role_users(role_id, users).collect { |u| u.to_attrs }
      rescue LookerSDK::NotFound => e
        say_error "set_role_users(#{role_id},#{JSON.pretty_generate(users)}) not found"
        say_error e
        say_error e.errors if e.errors
        raise
      rescue LookerSDK::Error => e
        say_error "Unable to call set_role_users(#{role_id},#{JSON.pretty_generate(users)})"
        say_error e
        say_error e.errors if e.errors
        raise
      end
    end

    def create_role(name,pset,mset)
      req = { name: name, permission_set_id: pset, model_set_id: mset }
      begin
        @sdk.create_role(req)&.to_attrs
      rescue LookerSDK::Error => e
        say_error "Unable to call create_role(#{JSON.pretty_generate(req)})"
        say_error e
        raise
      end
    end
  end
end
