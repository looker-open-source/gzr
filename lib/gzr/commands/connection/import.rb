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

require_relative '../../../gzr'
require_relative '../../command'
require_relative '../../modules/connection'
require_relative '../../modules/filehelper'

module Gzr
  module Commands
    class Connection
      class Import < Gzr::Command
        include Gzr::Connection
        include Gzr::FileHelper
        def initialize(file, options)
          super()
          @file = file
          @options = options
        end

        def execute(input: $stdin, output: $stdout)
          say_warning("options: #{@options.inspect}", output: output) if @options[:debug]
          with_session do
            connection = nil

            if @options[:prompt]
              reader = TTY::Reader.new
              @secret = reader.read_line("Enter your connection password:", echo: false)
            end

            read_file(@file) do |data|
              if !!cat_connection(data[:name])
                name = data[:name]
                if !@options[:force]
                  raise Gzr::CLI::Error, "Connection #{name} already exists\nUse --force if you want to overwrite it"
                end
                data.select! do |k,v|
                  keys_to_keep('update_connection').include? k
                end
                data[:password] = @secret if @secret
                connection = update_connection(name, data)
              else
                data.select! do |k,v|
                  keys_to_keep('create_connection').include? k
                end
                data[:password] = @secret if @secret
                connection = create_connection(data)
              end
              output.puts "Imported connection #{connection[:name]}" unless @options[:plain]
              output.puts connection[:id] if @options[:name]
            end
          end
        end
      end
    end
  end
end
