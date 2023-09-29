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
  module Connection

    def query_all_connections(fields=nil)
      begin
        @sdk.all_connections(fields ? {:fields=>fields} : nil ).collect { |e| e.to_attrs }
      rescue LookerSDK::Error => e
          say_error "Error querying all_connections({:fields=>\"#{fields}\"})"
          say_error e
          raise
      end
    end

    def query_all_dialects(fields=nil)
      begin
        @sdk.all_dialect_infos(fields ? {:fields=>fields} : nil ).collect { |e| e.to_attrs }
      rescue LookerSDK::Error => e
          say_error "Error querying all_dialect_infos({:fields=>\"#{fields}\"})"
          say_error e
          raise
      end
    end

    def test_connection(name, tests=nil)
      if tests.nil?
        connection = cat_connection(name)
        return nil if connection.nil?
        tests = connection[:dialect][:connection_tests]
      end

      begin
        @sdk.test_connection(name, {}, tests: tests).collect { |e| e.to_attrs }
      rescue LookerSDK::NotFound => e
        return []
      rescue LookerSDK::Error => e
        say_error "Error executing test_connection(#{name},#{tests})"
        say_error e
        raise
      end
    end

    def delete_connection(name)
      begin
        @sdk.delete_connection(name)
      rescue LookerSDK::NotFound => e
        say_warning "Connection #{name} not found"
      rescue LookerSDK::Error => e
        say_error "Error executing delete_connection(#{name})"
        say_error e
        raise
      end
    end

    def create_connection(body)
      begin
        @sdk.create_connection(body).to_attrs
      rescue LookerSDK::Error => e
        say_error "Error executing create_connection(#{JSON.pretty_generate(body)})"
        say_error e
        raise
      end
    end

    def update_connection(name,body)
      begin
        @sdk.update_connection(name,body).to_attrs
      rescue LookerSDK::NotFound => e
        say_warning "Connection #{name} not found"
      rescue LookerSDK::Error => e
        say_error "Error executing update_connection(#{name},#{JSON.pretty_generate(body)})"
        say_error e
        raise
      end
    end

    def cat_connection(name)
      begin
        @sdk.connection(name).to_attrs
      rescue LookerSDK::NotFound => e
        nil
      rescue LookerSDK::Error => e
        say_error "Error executing connection(#{name})"
        say_error e
        raise
      end
    end

    def trim_connection(data)
      data.select do |k,v|
        (keys_to_keep('create_connection') + [:pdt_context_override]).include? k
      end
    end
  end
end
