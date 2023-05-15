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
  module Model
    module Set

      def all_model_sets(fields=nil)
        req = {}
        req[:fields] = fields if fields
        begin
          return @sdk.all_model_sets(req)
        rescue LookerSDK::NotFound => e
          return nil
        rescue LookerSDK::Error => e
          say_error "Error querying all_model_sets(#{JSON.pretty_generate(req)})"
          say_error e
          raise
        end
      end

      def cat_model_set(set_id, fields=nil)
        req = {}
        req[:fields] = fields if fields
        begin
          return @sdk.model_set(set_id,req)&.to_attrs
        rescue LookerSDK::NotFound => e
          return nil
        rescue LookerSDK::Error => e
          say_error "Error querying model_set(#{set_id},#{JSON.pretty_generate(req)})"
          say_error e
          raise
        end
      end

      def trim_model_set(data)
        trimmed = data.select do |k,v|
          (keys_to_keep('update_model_set') + [:id,:built_in]).include? k
        end
        trimmed
      end

      def search_model_sets(fields: nil, sorts: nil, id: nil, name: nil, all_access: nil, built_in: nil, filter_or: nil)
        data = []
        begin
          req = {}
          req[:fields] = fields unless fields.nil?
          req[:sorts] = sorts unless sorts.nil?
          req[:id] = id unless id.nil?
          req[:name] = name unless name.nil?
          req[:all_access] = all_access unless all_access.nil?
          req[:built_in] = built_in unless built_in.nil?
          req[:filter_or] = filter_or unless filter_or.nil?
          req[:limit] = 64
          loop do
            page = @sdk.search_model_sets(req)
            data+=page
            break unless page.length == req[:limit]
            req[:offset] = (req[:offset] || 0) + req[:limit]
          end
        rescue LookerSDK::NotFound => e
          # do nothing
        rescue LookerSDK::Error => e
          say_error "Error calling search_model_sets(#{JSON.pretty_generate(req)})"
          say_error e
          raise
        end
        data
      end

      def update_model_set(model_set_id, data)
        begin
          return @sdk.update_model_set(model_set_id, data)&.to_attrs
        rescue LookerSDK::Error => e
          say_error "Error calling update_model_set(#{model_set_id},#{JSON.pretty_generate(data)})"
          say_error e
          raise
        end
      end

      def create_model_set(data)
        begin
          return @sdk.create_model_set(data)&.to_attrs
        rescue LookerSDK::Error => e
          say_error "Error calling create_model_set(#{JSON.pretty_generate(data)})"
          say_error e
          raise
        end
      end

      def delete_model_set(model_set_id)
        begin
          return @sdk.delete_model_set(model_set_id)
        rescue LookerSDK::Error => e
          say_error "Error calling delete_model_set(#{model_set_id}})"
          say_error e
          raise
        end
      end

    end
  end
end
