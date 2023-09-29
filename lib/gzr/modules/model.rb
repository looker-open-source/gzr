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
    def query_all_lookml_models(fields=nil, progress=false)
      data = []
      begin
        req = Hash.new
        req[:fields] = fields if fields
        req[:limit] = 16
        loop do
          puts "fetching #{req[:limit]} offset #{req[:offset] || 0}" if progress
          page = @sdk.all_lookml_models(req).collect { |m| m.to_attrs }
          data+=page
          break unless page.length == req[:limit]
          req[:offset] = (req[:offset] || 0) + req[:limit]
        end
      rescue LookerSDK::Error => e
        say_error "Error querying all_lookml_models(#{JSON.pretty_generate(req)})"
        say_error e
        raise
      end
      data
    end

    def cat_model(model_name)
      begin
        @sdk.lookml_model(model_name)&.to_attrs
      rescue LookerSDK::NotFound => e
        return nil
      rescue LookerSDK::Error => e
        say_error "Error getting lookml_model(#{model_name})"
        say_error e
        raise
      end
    end

    def trim_model(data)
      data.select do |k,v|
        keys_to_keep('create_lookml_model').include? k
      end
    end

    def create_model(body)
      begin
        @sdk.create_lookml_model(body)&.to_attrs
      rescue LookerSDK::Error => e
        say_error "Error running create_lookml_model(#{JSON.pretty_generate(body)})"
        say_error e
        raise
      end
    end

    def update_model(model_name,body)
      begin
        @sdk.update_lookml_model(model_name,body)&.to_attrs
      rescue LookerSDK::Error => e
        say_error "Error running update_lookml_model(#{model_name},#{JSON.pretty_generate(body)})"
        say_error e
        raise
      end
    end

  end
end
