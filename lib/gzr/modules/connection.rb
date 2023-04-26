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
  module Connection

    def query_all_connections(fields=nil)
      data = nil
      begin
        data = @sdk.all_connections(fields ? {:fields=>fields} : nil )
      rescue LookerSDK::Error => e
          say_error "Error querying all_connections({:fields=>\"#{fields}\"})"
          say_error e
          raise
      end
      data
    end

    def query_all_dialects(fields=nil)
      data = nil
      begin
        data = @sdk.all_dialect_infos(fields ? {:fields=>fields} : nil )
      rescue LookerSDK::Error => e
          say_error "Error querying all_dialect_infos({:fields=>\"#{fields}\"})"
          say_error e
          raise
      end
      data
    end

    def cat_connection(name)
      data = nil
      begin
        data = @sdk.connection(name).to_attrs
      rescue LookerSDK::NotFound => e
        say_warning "Connection #{name} not found"
      rescue LookerSDK::Error => e
        say_error "Error executing connection(#{name})"
        say_error e
        raise
      end
      data
    end

    def trim_connection(data)
      data.select do |k,v|
        (keys_to_keep('create_connection') + [:pdt_context_override]).include? k
      end
    end
  end
end
