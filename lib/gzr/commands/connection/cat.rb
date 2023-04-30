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

require 'json'
require_relative '../../command'
require_relative '../../modules/connection'
require_relative '../../modules/filehelper'

module Gzr
  module Commands
    class Connection
      class Cat < Gzr::Command
        include Gzr::Connection
        include Gzr::FileHelper
        def initialize(connection_id,options)
          super()
          @connection_id = connection_id
          @options = options
        end

        def execute(*args, input: $stdin, output: $stdout)
          say_warning("options: #{@options.inspect}") if @options[:debug]
          with_session do
            data = cat_connection(@connection_id)
            if data.nil?
              say_warning "Connection #{@connection_id} not found"
              return
            end
            data = trim_connection(data) if @options[:trim]

            outputJSON = JSON.pretty_generate(data)

            file_name = if @options[:dir]
                          @options[:simple_filename] ? "Connection_#{data[:name]}.json" : "Connection_#{data[:name]}_#{data[:dialect_name]}.json"
                        else
                          nil
                        end
            write_file(file_name, @options[:dir], nil, output) do |f|
              f.puts outputJSON
            end
          end
        end
      end
    end
  end
end
