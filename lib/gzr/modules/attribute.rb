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
  module Attribute
    def query_user_attribute(attr_id,fields=nil)
      data = nil
      begin
        req = {}
        req[:fields] = fields if fields
        data = @sdk.user_attribute(attr_id,req)
      rescue LookerSDK::NotFound => e
        # do nothing
      rescue LookerSDK::Error => e
        say_error "Error querying user_attribute(#{attr_id},#{JSON.pretty_generate(req)})"
        say_error e.message
        raise
      end
      data
    end

    def query_all_user_attributes(fields=nil, sorts=nil)
      data = nil
      begin
        req = {}
        req[:fields] = fields if fields
        req[:sorts] = sorts if sorts
        data = @sdk.all_user_attributes(req)
      rescue LookerSDK::Error => e
        say_error "Error querying all_user_attributes(#{JSON.pretty_generate(req)})"
        say_error e.message
        raise
      end
      data
    end

    def get_attribute_by_name(name, fields = nil)
      data = query_all_user_attributes(fields).select {|a| a.name == name}
      return nil if data.empty?
      data.first
    end

    def get_attribute_by_label(label, fields = nil)
      data = query_all_user_attributes(fields).select {|a| a.label == label}
      return nil if data.empty?
      data.first
    end

    def create_attribute(attr)
      data = nil
      begin
        data = @sdk.create_user_attribute(attr)
      rescue LookerSDK::Error => e
        say_error "Error creating user_attribute(#{JSON.pretty_generate(attr)})"
        say_error e.message
        raise
      end
      data
    end

    def update_attribute(id,attr)
      data = nil
      begin
        data = @sdk.update_user_attribute(id,attr)
      rescue LookerSDK::Error => e
        say_error "Error updating user_attribute(#{id},#{JSON.pretty_generate(attr)})"
        say_error e.message
        raise
      end
      data
    end

    def delete_user_attribute(id)
      data = nil
      begin
        data = @sdk.delete_user_attribute(id)
      rescue LookerSDK::Error => e
        say_error "Error deleting user_attribute(#{id})"
        say_error e.message
        raise
      end
      data
    end

    def upsert_user_attribute(source, force=false, output: $stdout)
      name_used = get_attribute_by_name(source[:name])
      if name_used
        raise(Gzr::CLI::Error, "Attribute #{source[:name]} already exists and can't be modified") if name_used[:is_system]
        raise(Gzr::CLI::Error, "Attribute #{source[:name]} already exists\nUse --force if you want to overwrite it") unless @options[:force]
      end

      label_used = get_attribute_by_label(source[:label])
      if label_used
        raise(Gzr::CLI::Error, "Attribute with label #{source[:label]} already exists and can't be modified") if label_used[:is_system]
        raise(Gzr::CLI::Error, "Attribute with label #{source[:label]} already exists\nUse --force if you want to overwrite it") unless force
      end

      existing = name_used || label_used
      if existing
        upd_attr = source.select do |k,v|
          keys_to_keep('update_user_attribute').include?(k) && !(name_used[k] == v)
        end

        return update_attribute(existing.id,upd_attr)
      else
        new_attr = source.select do |k,v|
          (keys_to_keep('create_user_attribute') - [:hidden_value_domain_whitelist]).include? k
        end
        new_attr[:hidden_value_domain_whitelist] = source[:hidden_value_domain_whitelist] if source[:value_is_hidden] && source[:hidden_value_domain_whitelist]

        return create_attribute(new_attr)
      end
    end
  end
end